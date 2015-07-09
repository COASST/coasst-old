class Array
  def to_h(&block)
    Hash[*self.collect{ |k,v| 
      [v,k]
    }.flatten]
  end

	def map_to_hash
		map { |e| yield e }.inject({}) { |carry, e| carry.merge! e }
	end
end
