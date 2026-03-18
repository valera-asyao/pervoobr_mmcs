require "minitest/autorun"
require_relative "../lib/pervoobr_mmcs"

module TestHelpers
  def set_ivars(obj, vars)
    vars.each do |k, v|
      obj.instance_variable_set(k.to_s, v)
    end
    obj
  end
end

class Minitest::Test
  include TestHelpers
end