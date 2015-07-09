require 'test/unit'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..")
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "../lib")
require "init"


class TitlecaseCapitalizeTest < Test::Unit::TestCase

  def test_correct_conversion
    assert_equal(String.new("A wind of the world").titlecase, 'A Wind of the World'))
  end
end
