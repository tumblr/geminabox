require 'test_helper'

class HooksTest < MiniTest::Unit::TestCase
  class Stub
    def initialize(out)
      @out = out
    end

    def stuff(foo)
      @out << foo
    end
  end

  test "end to end" do
    hooks = Geminabox::Hooks.new
    out = []

    hooks.observe{|foo| out << foo }
    hooks.observe lambda{|foo| out << foo }
    hooks.observe Stub.new(out), :stuff

    hooks.call("A")

    assert_equal ["A"]*3, out

    hooks.call("B")

    assert_equal ["A"]*3 + ["B"]*3, out
  end
end
