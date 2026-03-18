# lib/antiderivative_generator/term.rb
module AntiderivativeGenerator
  module Terms
    class Base
      attr_reader :coefficient, :k, :b

      def initialize
        # Внешний коэффициент (a)
        @coefficient = rand(1..7) * [-1, 1].sample
        # Коэффициент перед x (k) - не равен 0
        @k = rand(2..5) 
        # Свободный член (b)
        @b = rand(-5..5)
      end

      # Формирует красивую строку аргумента: (kx + b), (kx - b) или (kx)
      def arg_str
        return "(#{@k}x)" if @b.zero?
        b_sign = @b.positive? ? "+" : ""
        "(#{@k}x#{b_sign}#{@b})"
      end

      # Хелпер для сокращения дробей и форматирования коэффициентов
      def format_coeff(num, den = 1)
        res = Rational(num, den)
        return "" if res == 1
        return "-" if res == -1
        res.to_s
      end
    end

    class Polynomial < Base
      def initialize
        super
        @power = rand(1..4)
      end

      def question
        coeff = @coefficient.abs == 1 ? (@coefficient > 0 ? "" : "-") : @coefficient.to_s
        "#{coeff}#{arg_str}^#{@power}"
      end

      def answer
        new_power = @power + 1
        # Интеграл: (a / (k * (n+1))) * (kx + b)^(n+1)
        main_den = @k * new_power
        coeff = format_coeff(@coefficient, main_den)
        "#{coeff}#{arg_str}^#{new_power}"
      end
    end

    class Trigonometric < Base
      def initialize
        super
        @type = %i[sin cos].sample
      end

      def question
        coeff = @coefficient.abs == 1 ? (@coefficient > 0 ? "" : "-") : @coefficient.to_s
        "#{coeff}#{@type}#{arg_str}"
      end

      def answer
        new_type = @type == :sin ? 'cos' : 'sin'
        # Интеграл sin(kx+b) = -1/k * cos(kx+b)
        # Интеграл cos(kx+b) = 1/k * sin(kx+b)
        res_num = @type == :sin ? -@coefficient : @coefficient
        coeff = format_coeff(res_num, @k)
        "#{coeff}#{new_type}#{arg_str}"
      end
    end

    class Exponential < Base
      def question
        coeff = @coefficient.abs == 1 ? (@coefficient > 0 ? "" : "-") : @coefficient.to_s
        "#{coeff}e^#{arg_str}"
      end

      def answer
        # Интеграл a * e^(kx+b) = (a/k) * e^(kx+b)
        coeff = format_coeff(@coefficient, @k)
        "#{coeff}e^#{arg_str}"
      end
    end

    class Logarithmic < Base
      def question
        # Выглядит как: a / (kx + b)
        "#{@coefficient} / #{arg_str}"
      end

      def answer
        # Интеграл a / (kx + b) = (a/k) * ln|kx+b|
        coeff = format_coeff(@coefficient, @k)
        "#{coeff}ln|#{arg_str[1..-2]}|" # Убираем скобки для логарифма
      end
    end

    class Tangent < Base
      def question
        coeff = @coefficient.abs == 1 ? (@coefficient > 0 ? "" : "-") : @coefficient.to_s
        "#{coeff}tg#{arg_str}"
      end

      def answer
        # ∫ tg(kx+b) = -1/k * ln|cos(kx+b)|
        coeff = format_coeff(-@coefficient, @k)
        "#{coeff}ln|cos#{arg_str}|"
      end
    end

    class Cotangent < Base
      def question
        coeff = @coefficient.abs == 1 ? (@coefficient > 0 ? "" : "-") : @coefficient.to_s
        "#{coeff}ctg#{arg_str}"
      end

      def answer
        # ∫ ctg(kx+b) = 1/k * ln|sin(kx+b)|
        coeff = format_coeff(@coefficient, @k)
        "#{coeff}ln|sin#{arg_str}|"
      end
    end

    class PowerExponential < Base
      def initialize
        super
        @base = [2, 3, 5].sample # Основание 'a'
      end

      def question
        coeff = @coefficient.abs == 1 ? (@coefficient > 0 ? "" : "-") : @coefficient.to_s
        "#{coeff}#{@base}^#{arg_str}"
      end

      def answer
        # ∫ a^(kx+b) = (a^(kx+b)) / (k * ln(a))
        coeff = format_coeff(@coefficient, @k)
        # Поскольку ln(a) иррационален, выводим его в знаменателе строкой
        denom = coeff.include?('/') ? "#{coeff.split('/')[1]}ln(#{@base})" : "#{@k}ln(#{@base})"
        num = coeff.include?('/') ? coeff.split('/')[0] : @coefficient
        
        # Упрощенное форматирование для логарифма
        "#{num}/#{denom} * #{@base}^#{arg_str}"
      end
    end

    class ArctanTerm < Base
      def question
        "#{@coefficient} / (1 + #{arg_str}^2)"
      end

      def answer
        # ∫ 1 / (1 + (kx+b)^2) = 1/k * arctg(kx+b)
        coeff = format_coeff(@coefficient, @k)
        "#{coeff}arctg#{arg_str}"
      end
    end

  end
end