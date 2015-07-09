require 'test/unit'

class ArrayAsHashTest < Test::Unit::TestCase
  # Replace this with your real tests.
  def test_array_to_hash
		assert_equal({'key' => 'value', nil => 'Unspecified'}, 
								 [['key', 'vaue'], [nil, 'Unspecified']].to_h)
  end
end
