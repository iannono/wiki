string = ""
loop do
  string << "x" * 1024
  puts "#{string.size / 1024}K"
end
