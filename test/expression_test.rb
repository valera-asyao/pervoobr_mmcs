require_relative "test_helper"
require_relative "../lib/pervoobr_mmcs/expression"
require_relative "../lib/pervoobr_mmcs/term"

class ExpressionTest < Minitest::Test
  def test_question_string_has_prefix
    expr = AntiderivativeGenerator::Expression.allocate
    terms = [
      set_ivars(AntiderivativeGenerator::Terms::Polynomial.allocate, {
        "@coefficient" => 2, "@k" => 3, "@b" => 1, "@power" => 2
      })
    ]
    expr.instance_variable_set("@terms", terms)

    assert_equal "Найти первообразную для f(x) = 2(3x+1)^2", expr.question_string
  end

  def test_answer_string_has_prefix_and_constant
    expr = AntiderivativeGenerator::Expression.allocate
    terms = [
      set_ivars(AntiderivativeGenerator::Terms::Polynomial.allocate, {
        "@coefficient" => 2, "@k" => 3, "@b" => 1, "@power" => 2
      })
    ]
    expr.instance_variable_set("@terms", terms)

    assert_equal "F(x) = 2/9(3x+1)^3 + C", expr.answer_string
  end

  def test_build_string_with_mixed_signs
    expr = AntiderivativeGenerator::Expression.allocate

    t1 = set_ivars(AntiderivativeGenerator::Terms::Polynomial.allocate, {
      "@coefficient" => 2, "@k" => 3, "@b" => 1, "@power" => 2
    })

    t2 = set_ivars(AntiderivativeGenerator::Terms::Exponential.allocate, {
      "@coefficient" => -4, "@k" => 2, "@b" => 0
    })

    t3 = set_ivars(AntiderivativeGenerator::Terms::Logarithmic.allocate, {
      "@coefficient" => 6, "@k" => 3, "@b" => -5
    })

    expr.instance_variable_set("@terms", [t1, t2, t3])

    assert_equal(
      "Найти первообразную для f(x) = 2(3x+1)^2 - 4e^(2x) + 6 / (3x-5)",
      expr.question_string
    )

    assert_equal(
      "F(x) = 2/9(3x+1)^3 - 2e^(2x) + 2ln|3x-5| + C",
      expr.answer_string
    )
  end
end