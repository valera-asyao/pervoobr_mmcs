# frozen_string_literal: true
require_relative "lib/pervoobr_mmcs"

# Вспомогательные методы (должны быть выше!)

def normalize(answer)
  answer
    .gsub(/\s+/, '')           # Удаляем все пробелы
    .downcase                  # Приводим к нижнему регистру
    .gsub(/\+c$/, '+c')        # Нормализуем +C в конце
    .gsub(/-c$/, '-c')         # Нормализуем -C в конце
    .gsub(/\*\*/, '^')         # Заменяем ** на ^
end

def check_answer(user_answer, correct_answer)
  normalize(user_answer) == normalize(correct_answer)
end

def run_quiz(count, term_count)
  puts "\nРежим проверки (#{count} задач, #{term_count} слагаемых)"
  puts "Вводите ответы в формате: -6/5x^5 - 8cos(x) + C\n\n"
  
  score = 0
  
  count.times do |i|
    task = PervoobrMmcs.generate_task(term_count: term_count)
    
    puts "Задача #{i + 1} из #{count}:"
    puts task[:question]
    print "Ваш ответ: "
    user_answer = gets&.chomp&.strip
    
    if user_answer.nil? || user_answer.empty?
      puts "Пропущено"
      puts "Правильный ответ: #{task[:answer]}\n\n"
      next
    end
    
    if check_answer(user_answer, task[:answer])
      puts "Верно"
      score += 1
    else
      puts "Неверно"
      puts "Правильный ответ: #{task[:answer]}"
    end
    puts "-" * 40
  end
  
  puts "\nРезультаты:"
  puts "Правильных ответов: #{score} из #{count}"
  percentage = (score.to_f / count * 100).round(1)
  puts "Процент правильных: #{percentage}%"
  
  if percentage == 100
    puts "Отличный результат"
  elsif percentage >= 70
    puts "Хороший результат, но можно лучше"
  elsif percentage >= 50
    puts "Средний результат, можно лучше"
  else
    puts "Бро, тебе нужно тренироваться"
  end
  puts "\n"
end


# Основной код программы
if ARGV.length >= 1
  count = ARGV[0].to_i
  term_count = ARGV[1] ? ARGV[1].to_i : 3
  
  puts "Генерация #{count} задач с #{term_count} слагаемыми:\n\n"
  
  PervoobrMmcs.generate_tasks(count, term_count: term_count).each_with_index do |task, i|
    puts "Задача #{i + 1}:"
    puts task[:question]
    puts task[:answer]
    puts "-" * 40
  end
else
  puts "Генератор первообразных (режим проверки)"
  puts "Для выхода введите: exit, quit или \\q"
  puts "Команды:"
  puts "  generate [кол-во] [слагаемых] — показать задачи с ответами"
  puts "  quiz [кол-во] [слагаемых] — режим проверки с вводом ответов"
  puts "  test — одна задача на проверку\n\n"
  
  loop do
    print "> "
    input = gets&.chomp
    
    case input
    when 'exit', 'quit', '\\q'
      puts "Завершение работы..."
      break
    when /^generate(\s+(\d+))?(\s+(\d+))?/
      count = ($2 || 1).to_i
      term_count = ($4 || 3).to_i
      
      PervoobrMmcs.generate_tasks(count, term_count: term_count).each_with_index do |task, i|
        puts "\nЗадача #{i + 1}:"
        puts task[:question]
        puts task[:answer]
        puts "-" * 40
      end
    when /^quiz(\s+(\d+))?(\s+(\d+))?/
      count = ($2 || 1).to_i
      term_count = ($4 || 3).to_i
      run_quiz(count, term_count)
    when 'test', ''
      run_quiz(1, 3)
    else
      puts "Неизвестная команда. Используйте: generate, quiz или test"
    end
  end
end