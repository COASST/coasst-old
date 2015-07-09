class Name
  attr_reader :first_name, :middle_initial, :last_name

  def initialize(first_name, middle_initial, last_name)
    @first_name = first_name
    @middle_initial = middle_initial
    @last_name = last_name
  end

  def to_s
    [ @first_name, @middle_initial, @last_name ].compact.join(" ")
  end

  def tokens
    [ @first_name, @last_name].map { |l| l.downcase}
  end
end
