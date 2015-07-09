# Respace
class String
	def despace
		self.to_s.gsub(" ", "_")
	end

  def respace
    self.to_s.gsub("_", " ")
  end
end
