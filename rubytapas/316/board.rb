require "./cell"
name = "a"
BOARD = 5.times.map do |y|
  5.times.map do |x|
    cell = Cell.new(name)
    name = name.succ
    cell
  end
end

p BOARD
