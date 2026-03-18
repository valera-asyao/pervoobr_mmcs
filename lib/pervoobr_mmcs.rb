require_relative "pervoobr_mmcs/version"
require_relative "pervoobr_mmcs/expression"

module PervoobrMmcs
  class Error < StandardError; end

  # Генерация одной задачи с возможностью выбора количества слагаемых
  def self.generate_task(term_count: 3)
    expr = AntiderivativeGenerator::Expression.new(term_count)
    { question: expr.question_string, answer: expr.answer_string }
  end

  # Генерация нескольких задач
  def self.generate_tasks(count, term_count: 3)
    count.times.map { generate_task(term_count: term_count) }
  end
end