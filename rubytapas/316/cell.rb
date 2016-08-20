class Cell
  include Comparable
  attr_reader :name
 
  def initialize(name)
    @name = name
  end
 
  def inspect
    @name
  end
 
  def <=>(other)
    name <=> other.name
  end
 
  def hash
    [self.class, name].hash
  end
 
  alias_method :eql?, :==
end
