# Deep Copy
#
# ruby lacks deep copying, use marshal to create true duplicates
class Object
  def m_dup
    Marshal.load(Marshal.dump(self))
  end
end
