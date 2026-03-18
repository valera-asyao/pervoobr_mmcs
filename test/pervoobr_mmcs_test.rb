require_relative "test_helper"

class PervoobrMmcsTest < Minitest::Test
  def test_generate_task_returns_hash_with_question_and_answer
    task = PervoobrMmcs.generate_task(term_count: 3)

    assert_kind_of Hash, task
    assert task.key?(:question)
    assert task.key?(:answer)
    assert_includes task[:question], "Найти первообразную для f(x) ="
    assert_includes task[:answer], "F(x) ="
    assert_includes task[:answer], "+ C"
  end

  def test_generate_tasks_returns_requested_count
    tasks = PervoobrMmcs.generate_tasks(5, term_count: 2)

    assert_equal 5, tasks.size
    assert tasks.all? { |t| t.is_a?(Hash) && t[:question] && t[:answer] }
  end

  def test_generate_tasks_with_zero_count
    tasks = PervoobrMmcs.generate_tasks(0, term_count: 2)
    assert_equal [], tasks
  end
end