require_relative 'term'

module AntiderivativeGenerator
  class Expression
    attr_reader :terms

    def initialize(term_count = 3)
      @terms = Array.new(term_count) do
        [Terms::Polynomial, Terms::Trigonometric].sample.new
      end
    end

    def question_string
      "Найти первообразную для f(x) = #{build_string(:question)}"
    end

    def answer_string
      "F(x) = #{build_string(:answer)} + C"
    end

    private

    def build_string(method_name)
      result = ""
      @terms.each_with_index do |term, index|
        term_str = term.public_send(method_name)
        
        if index == 0
          # Для первого элемента минус пишем слитно, плюс не пишем
          result += term_str.start_with?('-') ? term_str : term_str.sub(/^[+]/, '')
        else
          # Для остальных добавляем пробелы вокруг знаков
          if term_str.start_with?('-')
            result += " - #{term_str[1..]}"
          else
            result += " + #{term_str.sub(/^[+]/, '')}"
          end
        end
      end
      result
    end
  end
end