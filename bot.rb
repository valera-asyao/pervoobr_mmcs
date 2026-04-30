# frozen_string_literal: true

require "json"
require "net/http"
require "uri"
require_relative "lib/pervoobr_mmcs"

module AnswerChecker
  module_function

  def normalize(answer)
    return "" if answer.nil?

    answer
      .gsub(/\s+/, "")
      .downcase
      .gsub(/\+c$/, "+c")
      .gsub(/-c$/, "-c")
      .gsub(/\*\*/, "^")
  end

  def correct?(user_answer, correct_answer)
    normalize(user_answer) == normalize(correct_answer)
  end
end

class SessionStore
  def initialize
    @store = {}
  end

  def start_quiz(user_id, tasks)
    @store[user_id] = { tasks: tasks, index: 0, score: 0 }
  end

  def get(user_id)
    @store[user_id]
  end

  def active?(user_id)
    @store.key?(user_id)
  end

  def clear(user_id)
    @store.delete(user_id)
  end
end

class TelegramApi
  API_URL = "https://api.telegram.org".freeze

  def initialize(token)
    @token = token
  end

  def get_updates(offset:)
    request("getUpdates", { offset: offset, timeout: 30 })
  end

  def send_message(chat_id:, text:)
    request("sendMessage", { chat_id: chat_id, text: text })
  end

  private

  def request(method_name, payload)
    uri = URI("#{API_URL}/bot#{@token}/#{method_name}")
    response = Net::HTTP.post(uri, JSON.dump(payload), "Content-Type" => "application/json")
    parsed = JSON.parse(response.body)
    raise "Telegram API error: #{parsed}" unless parsed["ok"]

    parsed["result"]
  rescue StandardError => e
    warn("API request failed for #{method_name}: #{e.message}")
    nil
  end
end

def parse_int(raw, default, min:, max:)
  value = raw.to_i
  value = default if raw.nil? || raw.empty? || value <= 0
  [[value, min].max, max].min
end

def parse_command(text)
  parts = text.to_s.strip.split(/\s+/)
  [parts.shift.to_s, parts]
end

def help_text
  <<~TEXT
    Я бот-генератор первообразных.
    Функционал:

    /generate [количество заданий] [количество функций] - показать задачи с ответами
    /quiz [количество заданий] [количество функций] - режим проверки (вводите ответы сообщениями)
    /test - быстрая проверка: 1 задача, 3 слагаемых
    /skip - пропустить текущий вопрос в викторине
    /cancel - отменить текущую викторину
    /help - показать справку

    Примеры:
    /generate 3 4
    /quiz 5 2
  TEXT
end

def quiz_question_text(session)
  task = session[:tasks][session[:index]]
  question_number = session[:index] + 1
  total = session[:tasks].size

  <<~TEXT
    Задача #{question_number} из #{total}:
    #{task[:question]}

    Введите ответ в формате:
    F(x) = ... + C
  TEXT
end

def quiz_result_text(score, total)
  percentage = (score.to_f / total * 100).round(1)
  message =
    if percentage == 100
      "Отличный результат"
    elsif percentage >= 70
      "Хороший результат, но можно лучше"
    elsif percentage >= 50
      "Средний результат, можно лучше"
    else
      "Бро, тебе нужно потренироваться"
    end

  <<~TEXT
    Результаты:
    Правильных ответов: #{score} из #{total}
    Процент правильных: #{percentage}%
    #{message}
  TEXT
end

def handle_command(api, sessions, user_id, chat_id, command, args)
  case command
  when "/start", "/help"
    api.send_message(chat_id: chat_id, text: help_text)
  when "/generate"
    count = parse_int(args[0], 1, min: 1, max: 20)
    term_count = parse_int(args[1], 3, min: 1, max: 10)
    tasks = PervoobrMmcs.generate_tasks(count, term_count: term_count)
    body = tasks.map.with_index(1) do |task, index|
      "Задача #{index}:\n#{task[:question]}\n#{task[:answer]}"
    end.join("\n\n")
    api.send_message(chat_id: chat_id, text: body)
  when "/quiz"
    count = parse_int(args[0], 1, min: 1, max: 20)
    term_count = parse_int(args[1], 3, min: 1, max: 10)
    tasks = PervoobrMmcs.generate_tasks(count, term_count: term_count)
    sessions.start_quiz(user_id, tasks)
    api.send_message(chat_id: chat_id, text: "Режим проверки запущен. Всего задач: #{count}.")
    api.send_message(chat_id: chat_id, text: quiz_question_text(sessions.get(user_id)))
  when "/test"
    tasks = PervoobrMmcs.generate_tasks(1, term_count: 3)
    sessions.start_quiz(user_id, tasks)
    api.send_message(chat_id: chat_id, text: "Быстрый тест: 1 задача, 3 слагаемых.")
    api.send_message(chat_id: chat_id, text: quiz_question_text(sessions.get(user_id)))
  when "/skip"
    unless sessions.active?(user_id)
      api.send_message(chat_id: chat_id, text: "Сейчас нет активной викторины. Используйте /quiz или /test.")
      return
    end

    session = sessions.get(user_id)
    task = session[:tasks][session[:index]]
    api.send_message(chat_id: chat_id, text: "Пропущено.\nПравильный ответ:\n#{task[:answer]}")
    move_next_or_finish(api, sessions, user_id, chat_id)
  when "/cancel"
    sessions.clear(user_id)
    api.send_message(chat_id: chat_id, text: "Режим проверки отменен.")
  else
    api.send_message(chat_id: chat_id, text: "Неизвестная команда. Используйте /help.")
  end
end

def move_next_or_finish(api, sessions, user_id, chat_id)
  session = sessions.get(user_id)
  session[:index] += 1

  if session[:index] >= session[:tasks].size
    api.send_message(chat_id: chat_id, text: quiz_result_text(session[:score], session[:tasks].size))
    sessions.clear(user_id)
  else
    api.send_message(chat_id: chat_id, text: quiz_question_text(session))
  end
end

def handle_answer(api, sessions, user_id, chat_id, text)
  unless sessions.active?(user_id)
    api.send_message(chat_id: chat_id, text: "Нет активной викторины. Используйте /quiz, /test или /help.")
    return
  end

  session = sessions.get(user_id)
  task = session[:tasks][session[:index]]

  if AnswerChecker.correct?(text, task[:answer])
    session[:score] += 1
    api.send_message(chat_id: chat_id, text: "Верно.")
  else
    api.send_message(chat_id: chat_id, text: "Неверно.\nПравильный ответ:\n#{task[:answer]}")
  end

  move_next_or_finish(api, sessions, user_id, chat_id)
end

def load_env_file(path = ".env")
  return unless File.exist?(path)

  File.foreach(path) do |line|
    line = line.strip
    next if line.empty? || line.start_with?("#")

    key, value = line.split("=", 2)
    next if key.nil? || value.nil?

    ENV[key.strip] ||= value.strip
  end
end

load_env_file
token = ENV["TELEGRAM_TOKEN"]
raise "Missing TELEGRAM_TOKEN in ENV" if token.nil? || token.empty?

api = TelegramApi.new(token)
sessions = SessionStore.new
offset = 0

puts "Бот запущен"

loop do
  updates = api.get_updates(offset: offset)
  next if updates.nil?

  updates.each do |update|
    offset = update["update_id"] + 1
    message = update["message"]
    next if message.nil?

    text = message["text"].to_s.strip
    next if text.empty?

    user_id = message.dig("from", "id")
    chat_id = message.dig("chat", "id")
    next if user_id.nil? || chat_id.nil?

    command, args = parse_command(text)
    if command.start_with?("/")
      handle_command(api, sessions, user_id, chat_id, command, args)
    else
      handle_answer(api, sessions, user_id, chat_id, text)
    end
  end
end


#чтобы завершить работу бота нужно нажать ctrl + c
