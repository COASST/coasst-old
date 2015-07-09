# overload the boolean classes to have a text representation
class TrueClass
  def to_bs
    'Yes'
  end
end

class FalseClass
  def to_bs
    'No'
  end
end
