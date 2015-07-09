class Hash
  def sort_by_value
    self.map{|k,v| [k,v]}.sort {|a,b| b[1] <=> a[1]} 
  end
end
