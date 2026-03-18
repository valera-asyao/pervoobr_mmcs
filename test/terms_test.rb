require_relative "test_helper"
require_relative "../lib/pervoobr_mmcs/term"

class TermsTest < Minitest::Test
  Terms = AntiderivativeGenerator::Terms

  def test_arg_str_with_positive_b
    term = set_ivars(Terms::Base.allocate, { "@k" => 3, "@b" => 5 })
    assert_equal "(3x+5)", term.arg_str
  end

  def test_arg_str_with_negative_b
    term = set_ivars(Terms::Base.allocate, { "@k" => 4, "@b" => -2 })
    assert_equal "(4x-2)", term.arg_str
  end

  def test_arg_str_with_zero_b
    term = set_ivars(Terms::Base.allocate, { "@k" => 2, "@b" => 0 })
    assert_equal "(2x)", term.arg_str
  end

  def test_format_coeff_for_one
    term = Terms::Base.allocate
    assert_equal "", term.format_coeff(1, 1)
  end

  def test_format_coeff_for_minus_one
    term = Terms::Base.allocate
    assert_equal "-", term.format_coeff(-1, 1)
  end

  def test_format_coeff_reduces_fraction
    term = Terms::Base.allocate
    assert_equal "2/3", term.format_coeff(4, 6)
  end

  def test_polynomial_question
    term = set_ivars(Terms::Polynomial.allocate, {
      "@coefficient" => 5, "@k" => 2, "@b" => 3, "@power" => 4
    })

    assert_equal "5(2x+3)^4", term.question
  end

  def test_polynomial_answer
    term = set_ivars(Terms::Polynomial.allocate, {
      "@coefficient" => 5, "@k" => 2, "@b" => 3, "@power" => 4
    })

    assert_equal "1/2(2x+3)^5", term.answer
  end

  def test_polynomial_answer_negative_coefficient
    term = set_ivars(Terms::Polynomial.allocate, {
      "@coefficient" => -6, "@k" => 3, "@b" => -1, "@power" => 1
    })

    assert_equal "-(3x-1)^2", term.answer
  end

  def test_trigonometric_sin_question
    term = set_ivars(Terms::Trigonometric.allocate, {
      "@coefficient" => 3, "@k" => 2, "@b" => 1, "@type" => :sin
    })

    assert_equal "3sin(2x+1)", term.question
  end

  def test_trigonometric_sin_answer
    term = set_ivars(Terms::Trigonometric.allocate, {
      "@coefficient" => 3, "@k" => 2, "@b" => 1, "@type" => :sin
    })

    assert_equal "-3/2cos(2x+1)", term.answer
  end

  def test_trigonometric_cos_answer
    term = set_ivars(Terms::Trigonometric.allocate, {
      "@coefficient" => -4, "@k" => 5, "@b" => -2, "@type" => :cos
    })

    assert_equal "-4/5sin(5x-2)", term.answer
  end

  def test_exponential_question
    term = set_ivars(Terms::Exponential.allocate, {
      "@coefficient" => 7, "@k" => 5, "@b" => 0
    })

    assert_equal "7e^(5x)", term.question
  end

  def test_exponential_answer
    term = set_ivars(Terms::Exponential.allocate, {
      "@coefficient" => 7, "@k" => 5, "@b" => 0
    })

    assert_equal "7/5e^(5x)", term.answer
  end

  def test_logarithmic_question
    term = set_ivars(Terms::Logarithmic.allocate, {
      "@coefficient" => 6, "@k" => 3, "@b" => -4
    })

    assert_equal "6 / (3x-4)", term.question
  end

  def test_logarithmic_answer
    term = set_ivars(Terms::Logarithmic.allocate, {
      "@coefficient" => 6, "@k" => 3, "@b" => -4
    })

    assert_equal "2ln|3x-4|", term.answer
  end

  def test_tangent_answer
    term = set_ivars(Terms::Tangent.allocate, {
      "@coefficient" => 4, "@k" => 2, "@b" => 3
    })

    assert_equal "-2ln|cos(2x+3)|", term.answer
  end

  def test_cotangent_answer
    term = set_ivars(Terms::Cotangent.allocate, {
      "@coefficient" => -6, "@k" => 3, "@b" => 1
    })

    assert_equal "-2ln|sin(3x+1)|", term.answer
  end

  def test_arctan_term_answer
    term = set_ivars(Terms::ArctanTerm.allocate, {
      "@coefficient" => 8, "@k" => 4, "@b" => -5
    })

    assert_equal "2arctg(4x-5)", term.answer
  end

  def test_power_exponential_answer_with_fractional_coefficient
    term = set_ivars(Terms::PowerExponential.allocate, {
      "@coefficient" => 3, "@k" => 2, "@b" => 1, "@base" => 5
    })

    assert_equal "3/2/ln(5) * 5^(2x+1)", term.answer
  end

  def test_power_exponential_answer_should_be_mathematically_correct
    term = set_ivars(Terms::PowerExponential.allocate, {
      "@coefficient" => 4, "@k" => 2, "@b" => 1, "@base" => 3
    })

    assert_equal "2/ln(3) * 3^(2x+1)", term.answer
  end
end