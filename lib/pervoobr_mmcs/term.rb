module AntiderivativeGenerator
  module Terms
    # Базовый класс для слагаемого
    class Base
      def initialize
        @coefficient = rand(1..9) * [-1, 1].sample
      end

      def sign
        @coefficient.positive? ? '+' : '-'
      end

      def abs_coefficient
        @coefficient.abs == 1 ? '' : @coefficient.abs.to_s
      end
    end

    # Полиномиальное слагаемое (например, 3x^2 -> первообразная x^3)
    class Polynomial < Base
      def initialize
        super
        @power = rand(1..5)
      end

      def question
        "#{sign}#{abs_coefficient}x^#{@power}"
      end

      def answer
        new_power = @power + 1
        numerator = @coefficient.abs
        denominator = new_power

        # Форматируем дробь
        fraction = if (numerator % denominator).zero?
                     (numerator / denominator).to_s
                   else
                     "#{numerator}/#{denominator}"
                   end
        fraction = '' if fraction == '1'

        "#{sign}#{fraction}x^#{new_power}"
      end
    end

    # Тригонометрическое слагаемое (например, 2sin(x) -> первообразная -2cos(x))
    class Trigonometric < Base
      def initialize
        super
        @type = %i[sin cos].sample
      end

      def question
        "#{sign}#{abs_coefficient}#{@type}(x)"
      end

      def answer
        new_type = @type == :sin ? 'cos' : 'sin'
        value = "#{abs_coefficient}#{new_type}(x)"

        sign_for_answer = if @type == :sin
                            @coefficient.positive? ? '-' : '+'
                          else
                            @coefficient.positive? ? '+' : '-'
                          end

        "#{sign_for_answer}#{value}"
      end
    end
  end
end