## 274

```
"pig latin".gsub(/(\w)(\w+)/, "\\2\\1ay") # => "igpay atinlay"
```

```
“aabcccccaaa” => “a2b1c5a3”

"aabcccccaaa".gsub(/[[:alpha:]]+/) { |m|
  "#{m[0]}#{m.length}"
}

"aabcccccaaa".gsub(/([[:alpha:]])\1+/) { |m|
  "#{m[0]}#{m.length}"
}

# 找单引号， 双引号
%{This string has "various" 'kinds of' `quotation`}.
  scan(/((["'`])[^\2]*\2)/)
# => [["\"various\"", "\""], ["'kinds of'", "'"], ["`quotation`", "`"]]
``` 

## 275 Antique Shop

```
User = Struct.new(:firstname, :lastname)
```

```
require "./user"
require "./greet"
 
def show_deals(user)
  puts greet(user.firstname)
  puts
  puts "Here are today's super deals!"
  puts "..."
end
 
user = User.new("Tom", "Servo")
 
show_deals(user)

# >> Good morning, Tom
# >>
# >> Here are today's super deals!
# >> ...
```

```
require "./user"
 
def show_user_info(user)
  puts "Hello, #{user.firstname}"
  puts
  puts "Here is your current user info:"
  puts "First name: #{user.firstname}"
  puts "Last name: #{user.lastname}"
end
 
user = User.new("Tom", "Servo")
 
show_user_info(user)

# >> Hello, Tom
# >>
# >> Here is your current user info:
# >> First name: Tom
# >> Last name: Servo
```

```
require "./user"
require "./greet"
 
def show_user_info(user)
  puts greet(user.firstname)
  puts
  puts "Here is your current user info:"
  puts "First name: #{user.firstname}"
  puts "Last name: #{user.lastname}"
end
 
user = User.new("Tom", "Servo")
 
show_user_info(user)

# 问题出现了
# >> Good morning, Tom
# >>
# >> Here is your current user info:
# >> First name: Good morning, Tom
# >> Last name: Servo
 
```

```
def greet(name, now=Time.now)
  case now.hour
  when 0..11 then  name.prepend("Good morning, ")
  when 12..16 then name.prepend("Good afternoon, ")
  else             name.prepend("Good evening, ")
  end
end
```

```
require "./user"
require "./greet"
 
def show_purchase_history(user)
  name = user.firstname
  greeting = greet(name)
  puts name
  puts
  puts "Here are your recent purchases:"
  puts "..."
end
 
user = User.new("Tom", "Servo")
 
show_purchase_history(user)
 
# >> Good morning, Tom
# >>
# >> Here are your recent purchases:
# >> ...
```

## 276  Fattr

```
class Spartan
  attr_accessor :name
  attr_accessor :rank
  attr_accessor :serial_number
 
  def initialize(name: "John", rank: "Master Chief", serial_number: "117")
    @name = name
    @rank = rank
    @serial_number = serial_number
  end
end
```
这串代码不够简洁， 多处重复

```
require "fattr"
 
class Spartan
  fattr :name
  fattr :rank
  fattr :serial_number
end
 
s = Spartan.new
s.name                          # => nil
s.rank                          # => nil
s.name = "John"
s.name                          # => "John"
```

```
require "fattr"
 
class Spartan
  fattr :name => "John"
  fattr :rank => "Master Chief"
  fattr :serial_number => "117"
end
 
s = Spartan.new
s.name                          # => "John"
s.rank                          # => "Master Chief"
s.serial_number                 # => "117"
```

```
require "fattr"
 
class Spartan
  fattr :name => "John"
  fattr :rank => "Master Chief"
  fattr :serial_number => "117"
  fattr(:designation) { "#{name}-#{serial_number}" }
end
 
s = Spartan.new
s.designation                   # => "John-117"
 
s = Spartan.new
s.name = "Linda"
s.serial_number = "058"
s.designation                   # => "Linda-058"
s.name = "Kelly"
s.designation                   # => "Linda-058"
```

```
require "fattr"
 
class Spartan
  fattr :name => "John"
  fattr :rank => "Master Chief"
  fattr :serial_number => "117"
  fattr(:designation) { "#{name}-#{serial_number}" }
end
 
s = Spartan.new
s.name = "Linda"
s.serial_number = "058"
s.name                          # => "Linda"
s.serial_number                 # => "058"
s.name!
s.serial_number!
s.name                          # => "John"
s.serial_number                 # => "117"
```

```
require "fattr"
 
class Spartan
  fattr :name => "John"
  fattr :rank => "Master Chief"
  fattr :serial_number => "117"
  fattr(:designation) { "#{name}-#{serial_number}" }
 
  def initialize(**attributes)
    attributes.each do |k, v|
      public_send k, v
    end
  end
end
 
s = Spartan.new(name: "Linda", rank: "Petty Officer 2", serial_number: "058")
 
s.name                          # => "Linda"
s.rank                          # => "Petty Officer 2"
s.serial_number                 # => "058"
```

## 297 Test Spies

经典的单元测试应该分为3个部分：1： 编排 2： 演绎 3： 断言
首先编排测试的场景， 然后告诉被测试对象应该做什么， 最后判断输出是否是期待的值

但是原来我们编写rspec的时候， 往往是将2 和 3 颠倒了

```
RSpec.describe Thermostat do
 
  it "turns on the furnace when the temperature is too low" do
    thermometer = double(temp_f: 67)
    furnace     = double(turn_on: true)
    thermostat  = Thermostat.new(thermometer: thermometer, furnace: furnace)
 
    expect(furnace).to receive(:turn_on)
    thermostat.check_temperature
  end 
end
```

为了遵循这一习惯， 最新的rspec允许我们先演绎再断言

```
RSpec.describe Thermostat do
 
  it "turns on the furnace when the temperature is too low" do
    thermometer = double(temp_f: 67)
    furnace     = double(turn_on: true)
    thermostat  = Thermostat.new(thermometer: thermometer, furnace: furnace)
 
    # 如果你double对象的时候也double了对应的方法， 则rspec会记录这些方法的调用
    # 原理就是double的时候, 记录了double对象的方法
    thermostat.check_temperature
    expect(furnace).to have_received(:turn_on)
  end 
end
```

```
it "leaves the furnace when the temperature is comfortable" do
    thermometer = double(temp_f: 72)
    furnace     = double
    thermostat  = Thermostat.new(thermometer: thermometer, furnace: furnace)
 
    thermostat.check_temperature
    expect(furnace).to_not have_received(:turn_on) # 这个测试会失败, 因为没有double方法
end

it "leaves the furnace when the temperature is comfortable" do
    thermometer = double(temp_f: 72)
    furnace     = double(turn_on: true)
    thermostat  = Thermostat.new(thermometer: thermometer, furnace: furnace)
 
    thermostat.check_temperature
    expect(furnace).to_not have_received(:turn_on)
end

# 除此之外:
furnace = double.as_null_object # 会记录所有的消息
# 更简单的是:
furnace = spy
```

## 294 Predicate Return Value

用于断言的返回值
```
2.even?                         # => true
3.even?                         # => false
```

我们可能会写如下的判断逻辑
```
class Coffee
  attr_accessor :sweetener
 
  def sweetened?
    if sweetener
      true
    else
      false
    end
  end
end
```


```
class Coffee
  attr_accessor :sweetener
 
  def sweetened?
    sweetener
  end
end
```

基于这种写法， 我们在做判断的时候， 可以这样写

```
if sweetener = c.sweetened?
  puts "Coffee sweetened with #{sweetener}"
else
  puts "Coffee"
end
```

更进一步的简化

```
class Coffee
  attr_accessor :sweetener
  alias_method :sweetened?, :sweetener
end 
```


## 295: Predicate Return Value Part 2

接下来看看这种返回对象和nil的方式会造成的问题
```
File.size?("NONESUCH") # 文件不存在或者文件大小为0的时候， 返回nil, 否则返回字节数
```

```
File.write("foo", "hello")
File.write("bar", "world!")
 
File.size?("foo")               # => 5
File.size?("bar")               # => 6
 
# 在这种情况下做异或操作的时候， 就会出问题了
File.size("foo") ^ File.size("bar") # => 3
``` 

```
def coffee_to_json(coffee)
  { "is_sweetened" => coffee.sweetened? }.to_json
end
 
# 如果这个json是作为外部的api给其他系统使用， 
# 特别是非ruby语言的系统，就会造成问题
c = Coffee.new
coffee_to_json(c)
# => "{\"is_sweetened\":null}"
 
c.sweetener = "sweet & low"
coffee_to_json(c)
# => "{\"is_sweetened\":\"sweet & low\"}"
```

解决方案

```
class Coffee
  attr_accessor :sweetener
 
  def sweetened?
    !!sweetener
  end
end
```

## 303: Exception Test

主要是介绍针对exception的测试会出现的问题

```
require "rspec/autorun"
 
class Thermostat
  def initialize(thermometer:, furnace:)
    @thermometer = thermometer
    @furnace     = furnace
  end
 
  def check_temperature
    temp = @thermometer.temp_f
    if temp <= 67
      @furnace.turn_on or fail "Furnace could not be lit"
    end
  end
end
 
RSpec.describe Thermostat do
  it "raises an exception when the furnace fails to light" do
    thermometer = double(temp_f: 67)
    furnace     = double(turn_on: false)
    thermostat  = Thermostat.new(thermometer: thermometer, furnace: furnace)
 
    # 如果温度低于67， raise error
    expect { thermostat.check_temperature }.to raise_error
  end 
end
```

如果我们修改了代码, 测试依旧可以通过， 但是其实代码是有问题的

```
require "rspec/autorun"
 
class Thermostat
  def initialize(thermometer:, furnace:)
    @thermometer = thermometer
    @furnace     = furnace
  end
 
  def check_temperature
    temp = @thermometer.temp_f
    if temp <= 67
      @furnace.power_on or fail "Furnace could not be lit"
    end
  end
end
 
RSpec.describe Thermostat do
  it "raises an exception when the furnace fails to light" do
    thermometer = double(temp_f: 67)
    furnace     = double(turn_on: false)
    thermostat  = Thermostat.new(thermometer: thermometer, furnace: furnace)
 
    expect { thermostat.check_temperature }.to raise_error
  end
end
```

``` 
RSpec.describe Thermostat do
  it "raises an exception when the furnace fails to light" do
    thermometer = double(temp_f: 67)
    furnace     = double(turn_on: false)
    thermostat  = Thermostat.new(thermometer: thermometer, furnace: furnace)
 
    expect { thermostat.check_temperature }.to raise_error(/furnace could not be lit/i)
  end
end
```

## 299: Instance Spy

```
require "rspec/autorun"
 
class Furnace
  def turn_on
     true
  end
end
 
class Thermostat
  def initialize(thermometer:,furnace:)
    @thermometer = thermometer
    @furnace     = furnace
  end
 
  def check_temperature
    temp = @thermometer.temp_f
    if temp <= 67
      @furnace.turn_on or fail "Furnace could not be lit"
    end
  end
end
 
RSpec.describe Thermostat do
 
  it "turns on the furnace when the temperature is too low" do
    thermometer = double(temp_f: 67)
    furnace     = double.as_null_object
    thermostat  = Thermostat.new(thermometer: thermometer, furnace: furnace)
 
    thermostat.check_temperature
    expect(furnace).to have_received(:turn_on)
  end
 
  it "leaves the furnace when the temperature is comfortable" do
    thermometer = double(temp_f: 72)
    furnace     = spy
    thermostat  = Thermostat.new(thermometer: thermometer, furnace: furnace)
 
    thermostat.check_temperature
    # 这一行代码是有问题的， 如果我们将furnace的turn_on方法修改为switch_on
    # 这个测试依旧是会通过的
    expect(furnace).to_not have_received(:turn_on)
  end
 
  it "raises an exception when the furnace fails to light" do
    thermometer = double(temp_f: 67)
    furnace     = double(turn_on: false)
    thermostat  = Thermostat.new(thermometer: thermometer, furnace: furnace)
 
    expect { thermostat.check_temperature }.to raise_error
  end
 
end

```

```
require "rspec/autorun"
 
class Furnace
  def switch_on
    true
  end
end
 
class Thermostat
  def initialize(thermometer:,furnace:)
    @thermometer = thermometer
    @furnace     = furnace
  end
 
  def check_temperature
    temp = @thermometer.temp_f
    if temp <= 67
      @furnace.switch_on or fail "Furnace could not be lit"
    end
  end
end
 
RSpec.describe Thermostat do
 
  it "turns on the furnace when the temperature is too low" do
    thermometer = double(temp_f: 67)
    furnace     = double.as_null_object
    thermostat  = Thermostat.new(thermometer: thermometer, furnace: furnace)
 
    thermostat.check_temperature
    expect(furnace).to have_received(:switch_on)
  end
 
  it "leaves the furnace when the temperature is comfortable" do
    thermometer = double(temp_f: 72)
    furnace     = instance_spy("Furnace")
    thermostat  = Thermostat.new(thermometer: thermometer, furnace: furnace)
 
    thermostat.check_temperature
    # 如果没有这个方法就会报错
    expect(furnace).to_not have_received(:turn_on)
  end
 
  it "raises an exception when the furnace fails to light" do
    thermometer = double(temp_f: 67)
    furnace     = double(switch_on: false)
    thermostat  = Thermostat.new(thermometer: thermometer, furnace: furnace)
 
    expect { thermostat.check_temperature }.to raise_error
  end
 
end
```

## 298 File Find

如何在Ruby下查找文件

```
require 'pathname'
 
Pathname("~/Dropbox/rubytapas/090-class-self").expand_path.find do |path|
  p path
end
```

```
require 'pathname'
 
Pathname("~/Dropbox/rubytapas").expand_path.find do |path|
  if path.file? && (
    path.basename.to_s =~ /^RubyTapas(\d{3})\b.*\.mp4$/ ||
    path.basename.to_s =~ /^(\d{3})\b.*\.mp4$/) 
    p path
  end
end
```

```
require 'pathname'
 
Pathname("~/Dropbox/rubytapas").expand_path.find do |path|
  # 因为find方法会遍历所有的文件，包括子文件夹
  # 所以Find.prune用于忽略整个文件夹
  Find.prune if path.directory? && path.basename.to_s =~ /^xxx/
  if path.file? && (
      path.basename.to_s =~ /^RubyTapas(\d{3})\b.*\.mp4$/ ||
      path.basename.to_s =~ /^(\d{3})\b.*\.mp4$/)
    number   = $1
    next if path.basename.to_s =~ /sample/
    stats    = `avprobe #{path} 2>&1`
    duration = stats[/Duration: (\d{2}:\d{2}:\d{2})/, 1]
    puts "#{number} #{duration} #{path.basename}"
  end
end
```

## 419 Subprocesses Part 4: Redirection

``` 
pid = Process.spawn "cat", "temp.markdown", :out => "hello.txt"
Process.waitpid(pid)
File.read('hello.txt')
```

``` 
pid = Process.spawn "cat", "noexist.markdown", :out => "hello.txt", :err => "error.txt"
Process.waitpid(pid)
File.read('error.txt')
```

```
output, input = IO.pipe
output                          
input                           

pid = Process.spawn "cat", "temp.markdown", :out => input
Process.waitpid(pid)
input.close
output.read
```

```
file = open("output.markdown", "a")
pid = Process.spawn "cat", "temp.markdown", :out => file
Process.waitpid(pid)
file.close
File.read("output.markdown")
```

```
pid = Process.spawn "cat", "temp.markdown", :out => ["multiple.txt", "w"]
Process.waitpid(pid)
File.read("multiple.txt")

pid = Process.spawn "cat", "temp.markdown", :out => ["multiple.txt", "a"]
Process.waitpid(pid)
File.read("multiple.txt")
```

```
system "cat", "temp.markdown", :out => ["multiple.txt", "a"]
File.read("multiple.txt")
```

## 423 Subprocesses Part 5: SIGCHLD

先执行完毕的先显示

``` 
pids = []; (1..3).to_a.reverse.each {|n| pid = Process.spawn("sleep #{n}"); puts pid;  pids << pid;}; pids.each {|p| puts "waiting #{p}"; Process.waitpid(p);}
```

如果我们想按照执行完成的顺序显示
``` 
pids = []; (1..3).to_a.reverse.each {|n| pid = Process.spawn("sleep #{n}"); puts pid;  pids << pid;}; begin pid = Process.waitpid(-1); puts "Process #{pid} is finished!"; pids.delete(pid); end until pids.empty?
```

如果我们需要异步的处理这些字进程呢？ 即我们不需要显式的调用`waitpid`, 这样就不会阻塞我们命令的执行

``` 
start_time = Time.now
FileUtils.mkpath "previews"
(1..3).to_a.reverse.each do |n| 
  pid = Process.spawn("sleep #{n}"); 
  pids[pid] = :working
end
 
until pids.values.all?{|v| v == :done}
  repaint(pids, start_time)
  sleep 0.1
end 
```

``` 
trap("CHLD") do
  while pids.values.include?(:working) &&
    pid = Process.waitpid(-1, Process::WNOHANG)
    pids[pid] = :done
  end
end 
```

```
ruby repaint.rb
```

## 425 Limits

```
require "prime"
Prime.each { |n| puts n; }
```

```
pid = Process.spawn RbConfig.ruby, "/Users/ian/Work/wiki/rubytapas/425/cpu_asplode.rb", rlimit_cpu: 0.8
Process.waitpid pid
```

```
string = ""
loop do
  string << "x" * 1024
  puts "#{string.size / 1024}K"
end
```

```
pid = Process.spawn RbConfig.ruby, "/Users/ian/Work/wiki/rubytapas/425/rss_asplode.rb", rlimit_as: [2, 2]
Process.waitpid pid
```


## 414 Subprocesses Part 1: Basics

```
ls .
system('ls .')
```

但是system是阻塞式的
``` 
system('sleep 3')
puts "done"
```

而且和父进程共享一个标准输出

```
puts "Here comes some STDERR..."; system "ls /NOTEXIST"
```

system命令的实质就是ruby会起一个默认的shell， 然后在其中运行命令, 比如这个：

```
system "echo Time to make some $$!"
```

```
system "echo", "Time to make some $$!"
# >> Time to make some $$!
```

我们还可以控制system命令运行的环境

```
system "cd ~; pwd" 
system({"HOME" => "/tmp"}, "cd ~; pwd")

```

``` 
puts "before"; system("ls", [:out, :err] => "/dev/null"); puts "after"
```

system特别适合执行快速的， 简单的系统命令, 而且并不太关心输出的的情况


## 416 Subprocesses Part 2: Command Input Operator

通过system命令， 我们是命令执行的结果的， 而只能得到是否顺利执行
```
mediainfo "/users/ian/downloads/social.mp4" 
result = system('mediainfo "/users/ian/downloads/social.mp4"') 
```

```
result = `mediainfo "/users/ian/downloads/social.mp4"`
puts result.lines
```

在该命令中， 我们可以使用变量
```
filename = "/users/ian/downloads/social.mp4"
video_info = `mediainfo "#{filename}"`
puts video_info.lines[0..2]

system(%Q<mediainfo "#{filename}">)
```

如果我们要组合两个命令

```
`pwd`
%x(ls `pwd`)
```
而且这个命令也是阻塞式的, 它的问题是不能像system一定能改变运行环境， 而且默认不能返回标准错误输出

```
output = `ls NONEXIT`
output = `ls NONEXIT 2>&1`
```

## 417 Subprocesses Part 3: Spawn

```
(1..3).each {|n| puts n; system('sleep 3');}
```

``` 
(1..3).each {|n| puts n; Process.spawn('sleep 3');}
```

虽然程序是并行了， 但是我们并不知道每个命令什么时候完成, 我们需要找到一个方法去监测进程的完成
```
pid = Process.spawn("ls /"); Process.waitpid(pid)
```

所以我们可以改进一下:
``` 
pids = []; (1..3).each {|n| puts n; pids << Process.spawn('sleep 3');}; pids.each {|p| puts "waiting #{p}"; Process.waitpid(p);}
```

此外，还有一个问题， 如果我们开了子进程， 却任由它执行， 而不管它。 系统也不会主动的去回收它， 即使它的任务已经完成， 这种进程就称之为僵尸进程

```
(1..3).each {|n| puts n; pid = Process.spawn('sleep 3'); Process.detach(pid);}
```

## 358 Rule Table

``` def device_type(device) if device.os =~ /ios/m # i 代表什么？ if device.resolution.width > 1024 && device.resolution.height > 768 :ios_hi
    else
      :ios_lo
    end
  elsif device.os =~ /android/i
    if device.resolution.width >= 1280 &&
       device.resolution.height > 800
      if device.user_agent_misc =~ /inky/i
        :ereader
      else
        :android_hi
      end
    else
      :android_lo
    end
  else
    :unknown
  end
end
```

```
require "./conditionals"

device = OpenStruct.new(
  os: "Android",
  resolution: OpenStruct.new(
    width: 1430,
    height: 1080),
  user_agent_misc: "(Inky)")

device_type(device)             # => :hd_ereader

# 如果有更多的state需要管理， 代码会变得非常复杂和臃肿
```

```
require "./matchers"
require "./rule_table"

TABLE = RuleTable.new
TABLE.add_rule_for :ios_hi, MatchOs.new(/ios/i),
                            MatchWidth.new(1024..2732),
                            MatchHeight.new(768..2048)
TABLE.add_rule_for :ios_lo, MatchOs.new(/ios/i),
                            MatchWidth.new(0...1024),
                            MatchHeight.new(0...768)
TABLE.add_rule_for :android_hi, MatchOs.new(/android/i),
                                MatchWidth.new(1280..2560),
                                MatchHeight.new(800..1800)
TABLE.add_rule_for :android_lo, MatchOs.new(/android/i),
                                MatchWidth.new(0...1280),
                                MatchHeight.new(0...800)
TABLE.add_rule_for :ereader, MatchOs.new(/android/i),
                   MatchMisc.new(/inky/i)
TABLE.add_rule_for :unknown
```

```
MatchOs = Struct.new(:pattern) do
  def matches?(device)
    pattern === device.os
  end
end

MatchWidth = Struct.new(:pattern) do
  def matches?(device)
    pattern === device.resolution.width
  end
end

MatchHeight = Struct.new(:pattern) do
  def matches?(device)
    pattern === device.resolution.height
  end
end

MatchMisc = Struct.new(:pattern) do
  def matches?(device)
    pattern === device.user_agent_misc
  end
end
```

```
class RuleTable
  def initialize
    @rules = []
  end

  def add_rule_for(target, *matchers)
    @rules << [target, matchers]
  end

  def match(object)
    @rules.find{ |(target, matchers)|
      matchers.all?{ |m| m.matches?(object) }
    }.first
  end
end
```

## 359 Colored Logs

```
require "logger"
logger = Logger.new($stdout)
logger.formatter = ->(severity, datetime, progname, message) {
  "#{severity}: #{message}\n"
}

logger.debug "Logging enabled"
logger.info "Ready for launch"
logger.warn "These readings look weird"
logger.error "Tang reservoir empty!"
logger.fatal "Aborting launch"

# !> DEBUG: Logging enabled
# !> INFO: Ready for launch
# !> WARN: These readings look weird
# !> ERROR: Tang reservoir empty!
# !> FATAL: Aborting launch
```

```
require "pastel"

pastel = Pastel.new
pastel.blue("hello")
puts pastel.blue("hello")
puts pastel.yellow.bold.underline("hello")
puts pastel.red.on_green("Merry Christmas!")

cyan = pastel.cyan.detach
puts cyan.("Hello")
```

```
require "pastel"
require "logger"

logger = Logger.new($stdout)
pastel = Pastel.new

colors = {
  "FATAL" => pastel.red.bold.detach,
  "ERROR" => pastel.red.detach,
  "WARN"  => pastel.yellow.detach,
  "INFO"  => pastel.green.detach,
  "DEBUG" => pastel.white.detach,
}

logger.formatter = ->(severity, datetime, progname, message) {
  colorizer = colors[severity]
  "#{colorizer.(severity)}: #{message}\n"
}

logger.debug "Logging enabled"
logger.info "Ready for launch"
logger.warn "These readings look weird"
logger.error "Tang reservoir empty!"
logger.fatal "Aborting launch"
```

```
require "pastel"
require "logger"

logger = Logger.new($stdout)
pastel = Pastel.new
colors = {
  "FATAL" => pastel.red.bold.detach,
  "ERROR" => pastel.red.detach,
  "WARN"  => pastel.yellow.detach,
  "INFO"  => pastel.green.detach,
  "DEBUG" => pastel.white.detach,
}

logger.formatter = ->(severity, datetime, progname, message) {
  colorizer = $stdout.tty? ? colors[severity] : ->(s){s}
  "#{colorizer.(severity)}: #{message}\n"
}

logger.debug "Logging enabled"
logger.info "Ready for launch"
logger.warn "These readings look weird"
logger.error "Tang reservoir empty!"
logger.fatal "Aborting launch"
``` 

## 360 Assumptions

以下两种方法， 哪种的速度要快一些呢？
```
index     = 42
page_size = 10

# Separate operators
page   = index / page_size
offset = index % page_size

# Divmod
page, offset = index.divmod(page_size)
```

```
require "benchmark/ips"

index     = 42
page_size = 10

Benchmark.ips do |x|
  x.report("operators") do |times|
    1.upto(times) do
      index / page_size
      index % page_size
    end
  end

  x.report("divmod") do |times|
    1.upto(times) do
      index.divmod(page_size)
    end
  end

  x.compare!
end

ruby中所以的方法都是发送消息， 这两个实现的不同只是在于一个是发两个消息， 一个是发一个消息
```

```
code = <<EOL
index     = 42
page_size = 10
index / page_size
index % page_size
EOL

puts RubyVM::InstructionSequence.compile(code).disasm
```

```
code = <<EOL
index     = 42
page_size = 10
index.divmod(page_size)
EOL

puts
puts RubyVM::InstructionSequence.compile(code).disasm
```


## 349 Log Formatting

```
require "logger"
logger = Logger.new($stderr)
logger.formatter = ->(severity, datetime, progname, message) {
  "#{severity}: #{message}\n"
}

logger.info "Ready for launch"
logger.warn "These readings look weird"
logger.fatal "Aborting launch"

# !> INFO: Ready for launch
# !> WARN: These readings look weird
# !> FATAL: Aborting launch
```

```
logger = Logger.new($stderr)
logger.datetime_format = "%c"

logger.info "Ready for launch"
logger.warn "These readings look weird"
logger.fatal "Aborting launch"

# !> I, [Mon Sep  7 13:54:34 2015#26647]  INFO -- : Ready for launch
# !> W, [Mon Sep  7 13:54:34 2015#26647]  WARN -- : These readings look weird
# !> F, [Mon Sep  7 13:54:34 2015#26647] FATAL -- : Aborting launch
```

## 350 Logging Program Name

假设有两个进程
```
require "logger"
logger = Logger.new($stderr)

IO.popen "-" do |pipe|
  if pipe
    while widget = pipe.gets.chomp
      logger.info "Frobbing widget #{widget}"
    end
  else
    0.step.each do |i|
      sleep 0.5
      logger.info "Making widget #{i}"
      puts i
    end
  end
end

 $ ruby progname.rb
I, [2015-09-06T16:40:06.876645 #18121]  INFO -- : Making widget 0
I, [2015-09-06T16:40:06.877393 #18119]  INFO -- : Frobbing widget 0
I, [2015-09-06T16:40:07.377402 #18121]  INFO -- : Making widget 1
I, [2015-09-06T16:40:07.377793 #18119]  INFO -- : Frobbing widget 1
I, [2015-09-06T16:40:07.877898 #18121]  INFO -- : Making widget 2
I, [2015-09-06T16:40:07.878208 #18119]  INFO -- : Frobbing widget 2
I, [2015-09-06T16:40:08.378325 #18121]  INFO -- : Making widget 3
I, [2015-09-06T16:40:08.378575 #18119]  INFO -- : Frobbing widget 3
I, [2015-09-06T16:40:08.878776 #18121]  INFO -- : Making widget 4
I, [2015-09-06T16:40:08.879089 #18119]  INFO -- : Frobbing widget 4
I, [2015-09-06T16:40:09.379210 #18121]  INFO -- : Making widget 5
I, [2015-09-06T16:40:09.379578 #18119]  INFO -- : Frobbing widget 5
I, [2015-09-06T16:40:09.879679 #18121]  INFO -- : Making widget 6
I, [2015-09-06T16:40:09.879991 #18119]  INFO -- : Frobbing widget 6
```


```
IO.popen "-" do |pipe|
  if pipe
    logger.progname = "parent"
    while widget = pipe.gets.chomp
      logger.info "Frobbing widget #{widget}"
    end
  else
    logger.progname = "child"
    0.step.each do |i|
      sleep 0.5
      logger.info "Making widget #{i}"
      puts i
    end
  end
end
$ ruby progname2.rb
I, [2015-09-06T16:44:00.935039 #18147]  INFO -- child: Making widget 0
I, [2015-09-06T16:44:00.935767 #18145]  INFO -- parent: Frobbing widget 0
I, [2015-09-06T16:44:01.435818 #18147]  INFO -- child: Making widget 1
I, [2015-09-06T16:44:01.436136 #18145]  INFO -- parent: Frobbing widget 1
I, [2015-09-06T16:44:01.936254 #18147]  INFO -- child: Making widget 2
I, [2015-09-06T16:44:01.936599 #18145]  INFO -- parent: Frobbing widget 2
I, [2015-09-06T16:44:02.436726 #18147]  INFO -- child: Making widget 3
I, [2015-09-06T16:44:02.437098 #18145]  INFO -- parent: Frobbing widget 3
I, [2015-09-06T16:44:02.937181 #18147]  INFO -- child: Making widget 4
I, [2015-09-06T16:44:02.937567 #18145]  INFO -- parent: Frobbing widget 4
I, [2015-09-06T16:44:03.437682 #18147]  INFO -- child: Making widget 5
I, [2015-09-06T16:44:03.438020 #18145]  INFO -- parent: Frobbing widget 5
I, [2015-09-06T16:44:03.938111 #18147]  INFO -- child: Making widget 6
I, [2015-09-06T16:44:03.938425 #18145]  INFO -- parent: Frobbing widget 6
```

```
# producer.rb file
require "logger"
logger = Logger.new($stderr)
logger.progname = $PROGRAM_NAME

logger.info "Hello, world"
logger.info "Well, be seein' ya!"

$ ruby producer.rb
I, [2015-09-07T14:05:03.487813 #26746]  INFO -- producer.rb: Hello, world
I, [2015-09-07T14:05:03.487882 #26746]  INFO -- producer.rb: Well, be seein' ya!
```

## 351 Log Rotation

```
# 通过指定daily, logger文件可以自动按照日期保存
require "logger"
require "timecop"

logger = Logger.new("myprog.log", "daily")

logger.info "Hello, world"
Timecop.travel(Date.today + 1)
logger.info "Hello, again"
Timecop.travel(Date.today + 2)
logger.info "Hello, future!"

# result
$ ls *.log*
myprog.log  myprog.log.20150906  myprog.log.20150907
```

```
require "logger"
# 还可以指定日志的保留版本和文件的大小
logger = Logger.new("rotation.log", 4, 2048)

1000.times do |n|
  logger.info "This is log message ##{n}"
end
``` 

## 340

读取天气信息， 确认是否需要带伞
将读取时间缓存， 每隔一个小时才访问一次远程api
```
require "json"
require "net/http"
require "logger"

log = Logger.new($stderr)
log.level = Logger::INFO

zipcode = ARGV[0] or abort "You must supply a ZIP code"

cache_timestamp = File.exist?(zipcode) && File.new(zipcode).mtime

log.debug "Cache timestamp is #{cache_timestamp}"

cache_age = if cache_timestamp
              Time.now - cache_timestamp
            else
              Float::INFINITY
            end
log.info "Cache is #{cache_age} seconds old"


raw_data = if cache_age > 60 * 60
             log.info "Fetching data from server"
             uri = URI("http://api.openweathermap.org/data/2.5/weather?zip=#{zipcode},us")
             body = Net::HTTP.get_response(uri).body
             log.debug "Raw weather data:"
             log.debug body
             log.info "Writing data to cache"
             IO.write(zipcode, body)
             body
           else
             log.info "Fetching data from cache"
             IO.read(zipcode)
           end
log.debug raw_data

data = JSON.parse(raw_data)
weather_id = data.fetch("weather").fetch(0).fetch("id").to_i
if (200...600).include?(weather_id)
  puts "Take an umbrella"
else
  puts "No umbrella needed"
end
```

如何更改输出的日志级别呢？

# LOG_LEVEL=DEBUG ruby umbrella2.rb
```
require "json"
require "net/http"
require "logger"

log = Logger.new($stderr)
# 只需要动态的读取环境变量中的level参数即可
log.level = Logger.const_get(ENV.fetch("LOG_LEVEL", "INFO"))

zipcode = ARGV[0] or abort "You must supply a ZIP code"

cache_timestamp = File.exist?(zipcode) && File.new(zipcode).mtime

log.debug "Cache timestamp is #{cache_timestamp}"

cache_age = if cache_timestamp
              Time.now - cache_timestamp
            else
              Float::INFINITY
            end
log.info "Cache is #{cache_age} seconds old"


raw_data = if cache_age > 60 * 60
             log.info "Fetching data from server"
             uri = URI("http://api.openweathermap.org/data/2.5/weather?zip=#{zipcode},us")
             body = Net::HTTP.get_response(uri).body
             log.debug "Raw weather data:"
             log.debug body
             log.info "Writing data to cache"
             IO.write(zipcode, body)
             body
           else
             log.info "Fetching data from cache"
             IO.read(zipcode)
           end

log.debug raw_data
data = JSON.parse(raw_data)
weather_id = data.fetch("weather").fetch(0).fetch("id").to_i
if (200...600).include?(weather_id)
  puts "Take an umbrella"
else
  puts "No umbrella needed"
end
```

## 341 Hammers And Diapers

原本有一个用来发送ipn的rake任务

```
bundle exec rake send_ipn[kirk@example.org]
```

有一天， 我需要发送100多个地址， 于是我开始写新的rake任务, 并且修改原有的任务
写到一半的时候， 我去换尿布. 回来的时候， 我突然茅塞顿开。
我删掉我所有已经写的代码， 只用一行代码就完成了这个任务

```
cat missing_emails.txt | xargs -I {} bundle exec rake send_ipn[{}]
# OR
xargs -I {} bundle exec rake send_ipn[{}] < missing_emails.txt
```

## 342 Example Data

```
module Perkolator
  def self.process_ipn(params, redemption_url_template:, email_options:)
    email = params.fetch("payer_email") { "<MISSING_EMAIL>" }
    # lots more code....
  end
end
```

```
require "spec_helper"
require "perkolator"

RSpec.describe Perkolator do
  it "can handle an IPN callback" do
    params = { payer_email: "larry@example.org" }
    Perkolator.process_ipn(params)
  end
end
```

```
require "spec_helper"
require "perkolator"

RSpec.describe Perkolator do
  let(:redemption_url_template) {
    Addressable::Template.new("http://example.com/redeem?token={token}")
  }

  let(:email_options) {
    {
      address: "localhost",
      port:    1025
    }
  }

  it "can handle an IPN callback" do
    params = { payer_email: "larry@example.org" }
    Perkolator.process_ipn(params,
                           redemption_url_template: redemption_url_template,
                           email_options: email_options)
  end
end
```

如果想在命令行里面测试我们的方法呢？

```
module Perkolator
  # ...
  def self.example_redemption_url_template
    Addressable::Template.new("http://example.com/redeem?token={token}")
  end

  def self.example_email_options
    {
      address: "localhost",
      port:    1025
    }
  end

  def self.process_ipn(params,
                       redemption_url_template: example_redemption_url_template,
                       email_options:           example_email_options)
    email = params.fetch("payer_email") { "<MISSING_EMAIL>" }
    # much more code...
  end
end
```

## 331 Process Object

本地服务
```
require "sinatra"

module Services
  class PurchaseMonkeys
    def self.perform(user:, card_info:, quantity: 1)
      if can_purchase_monkey?(user)
        gateway = PaymentGateway.new
        price   = Monkey.current_price
        total   = price * quantity
        gateway.charge!(total, card_info)
        MonkeyWarehouse.ship_monkeys(quantity, user.address)
      end
    end

    def self.can_purchase_monkey?(user)
      rules = ShippingRegulations.latest
      rules.can_ship_to?(user.address.postal_code)
    end
  end
end

post "/purchase_monkeys" do
  card_info = params[:card_info]
  quantity  = params[:quantity].to_i
  user      = current_user
  result = Services::PurchaseMonkeys.perform(
    user:      user,
    card_info: card_info,
    quantity:  quantity)
  if result
    "Monkeys are on their way!"
  else
    "Sorry, no monkeys for you."
  end
end
```

现在服务改成远程服务
```
module Services
  class InitiateMonkeyPurchase
    def self.perform(user:, card_info:, quantity: 1)
      approval_request_id = ZooPS.request_shipping_approval(
        zip_code: user.address.postal_code,
        species: "monkey",
        callback: "https://example.com/zoops_callback")

      {
        user_id:     user.id,
        card_info:   card_info,
        quantity:    quantity,
        approval_id: approval_request_id
      }
    end
  end

  class CompleteMonkeyPurchase
    def self.perform(user:, card_info:, quantity:)
      gateway = PaymentGateway.new
      price   = Monkey.current_price
      total   = price * quantity
      gateway.charge!(total, card_info)
      MonkeyWarehouse.ship_monkeys(quantity, user.address)
    end
  end
end

post "/purchase_monkeys" do
  card_info = params[:card_info]
  quantity  = params[:quantity].to_i
  user      = current_user
  purchase_info = Services::InitiateMonkeyPurchase.perform(
    user:      user,
    card_info: card_info,
    quantity:  quantity)
  store_purchase_info(purchase_info)
  "Your purchase is pending approval"
end


post "/zoops_callback" do
  approval_id = params[:id]
  if params[:approved] == "yes"
    purchase_info = retrieve_purchase_info(approval_id)
    Services::CompleteMonkeyPurchase.perform(
      user: User.find(purchase_info[:user_id]),
      card_info: purchase_info[:card_info],
      quantity: purchase_info[:quantity])
  end
end
```

```
require "sinatra"

class MonkeyPurchase < SchmactiveRecord::Base
  attr_accessors :state, :user, :card_info, :quantity, :approval_id

  def initialize(user:, card_info:, quantity: 1)
    self.user      = user
    self.card_info = card_info
    self.quantity  = quantity
    self.state     = :ready
  end

  def submitted
    self.approval_id = ZooPS.request_shipping_approval(
      zip_code: user.address.postal_code,
      species: "monkey")
    self.state = :pending_approval
  end

  def shipping_approved
    gateway = PaymentGateway.new
    price   = Monkey.current_price
    total   = price * quantity
    gateway.charge!(total, card_info)
    MonkeyWarehouse.ship_monkeys(quantity, user.address)
    self.state = :complete
  end

  # ...
end

post "/purchase_monkeys" do
  card_info = params[:card_info]
  quantity  = params[:quantity].to_i
  user      = current_user
  purchase = MonkeyPurchase.new(
    user:      user,
    card_info: card_info,
    quantity:  quantity)
  purchase.submitted
  purchase.save!
  "Your purchase is pending approval"
end


post "/zoops_callback" do
  approval_id = params[:id]
  if params[:approved] == "yes"
    purchase = MonkeyPurchase.find_by_approval_id(approval_id)
    purchase.shipping_approved
    purchase.save!
  end
end
```

```
require "sinatra"

class MonkeyPurchase
  attr_accessors :state, :user, :card_info, :quantity

  def initialize(user:, card_info:, quantity: 1)
    self.user      = user
    self.card_info = card_info
    self.quantity  = quantity
    self.state     = :ready
  end

  def submitted
    if can_purchase_monkey?(user)
      gateway = PaymentGateway.new
      price   = Monkey.current_price
      total   = price * quantity
      gateway.charge!(total, card_info)
      MonkeyWarehouse.ship_monkeys(quantity, user.address)
      self.state = :complete
    else
      self.state = :failed
    end
  end

  private

  def can_purchase_monkey?(user)
    rules = ShippingRegulations.latest
    rules.can_ship_to?(user.address.postal_code)
  end
end

post "/purchase_monkeys" do
  card_info = params[:card_info]
  quantity  = params[:quantity].to_i
  user      = current_user
  purchase = MonkeyPurchase.new(
    user:      user,
    card_info: card_info,
    quantity:  quantity)
  purchase.submitted
  if purchase.state == :complete
    "Your monkeys are on their way!"
  else
    "We were unable to complete your purchase."
  end
end
```

## 332

在上一节中， 我们发送的是基于事件类型的消息
如果我们改成是基于状态的消息呢

```
class MonkeyPurchase < SchmactiveRecord::Base
  # ...
  def complete
    gateway = PaymentGateway.new
    price   = Monkey.current_price
    total   = price * quantity
    gateway.charge!(total, card_info)
    MonkeyWarehouse.ship_monkeys(quantity, user.address)
    self.state = :complete
  end
  # ...
end

# ...


post "/zoops_callback" do
  approval_id = params[:id]
  if params[:approved] == "yes"
    purchase = MonkeyPurchase.find_by_approval_id(approval_id)
    purchase.complete
    purchase.save!
  end
end
```

现在是两个步骤， 如果以后是三个步骤
比如需要根据gateway的异步结果才能确定步骤完成
那么我们就需要修改我们的方法， 将前一个状态的处理提出为单一的方法
同时还需要修改对应的api调用(post)

```
class MonkeyPurchase < SchmactiveRecord::Base
  # ...
  def process_payment
    gateway = PaymentGateway.new
    price   = Monkey.current_price
    total   = price * quantity
    charge_id = gateway.charge!(total, card_info) # 需要根据gateway的异步结果才能确定步骤完成
    enqueue_payment_poll_job(charge_id)
    self.state = :pending_payment
  end

  def ship_monkeys
    MonkeyWarehouse.ship_monkeys(quantity, user.address)
    self.state = :complete
  end
  # ...
end

post "/zoops_callback" do
  approval_id = params[:id]
  if params[:approved] == "yes"
    purchase = MonkeyPurchase.find_by_approval_id(approval_id)
    purchase.process_payment
    purchase.save!
  end
end
```

同时由于处理流程中有多个状态的转化
我们还需要考虑处理错误状态的情况

```
class MonkeyPurchase < SchmactiveRecord::Base
  # ...
  def process_payment
    return unless state == :pending_approval
    gateway = PaymentGateway.new
    price   = Monkey.current_price
    total   = price * quantity
    charge_id = gateway.charge!(total, card_info)
    enqueue_payment_poll_job(charge_id)
    self.state = :pending_payment
  end
  # ...
end
```

而如果我们按照业务的逻辑来设定方法， 则不会遇到这个问题

```
class MonkeyPurchase < SchmactiveRecord::Base
  # ...
  def shipping_approved
    return unless state == :pending_approval
    gateway = PaymentGateway.new
    price   = Monkey.current_price
    total   = price * quantity
    charge_id = gateway.charge!(total, card_info)
    enqueue_payment_poll_job(charge_id)
    self.state = :pending_payment
  end
  # ...
end

An essential element of object-oriented separation of concerns is object humility: an object should know its own business, and shouldn't try to make decisions for other objects.
```

## 333 Processes Everywhere

So in the end, it does not make sense to segregate "process objects" into their own directory. Our domain models are full of business processes; some are just more stable than others.

## 315 

``` 
require "./maze"


puts Maze.new(width: 10, height: 10).to_s
# => nil

# >> ---------------------
# >> |           |     | |
# >> - --------- --- - - -
# >> |   |       |   |   |
# >> - - - ------- ----- -
# >> | | | |     | |   | |
# >> - --- - --- - - - - -
# >> |   |   | | | | | | |
# >> - - ----- - - - --- -
# >> | |       | | | |   |
# >> - ----- - - - - - ---
# >> | | |   | | | | | | |
# >> - - - ----- - - - - -
# >> |   |   |   | |   | |
# >> - ----- - --- - --- -
# >> | |     | |   | |   |
# >> - - ----- --- - --- -
# >> | |     | |   |   | |
# >> - ----- - - ----- - -
# >> |     |     |       |
# >> ---------------------

```

ruby的random基于生成的seed， 每次生成seed都不同
``` 
Random::DEFAULT.seed            # => 130422514844656851045348920844218973837 
```

我们也可以指定seed

```
srand(12345)
rand(10)                        # => 2
rand(10)                        # => 5
rand(10)                        # => 1
rand(10)                        # => 4
 
srand(12345)
rand(10)                        # => 2
rand(10)                        # => 5
rand(10)                        # => 1
rand(10)                        # => 4
```

```
rng = Random.new(12345)
rng.rand(10)                    # => 2
rng.rand(10)                    # => 5
rng.rand(10)                    # => 1
rng.rand(10)                    # => 4
```

## 316 Each

迷宫格

```
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
```

生成迷宫盘(board.rb)

```
require "./cell"
name = "a"
BOARD = 5.times.map do |y|
  5.times.map do |x|
    cell = Cell.new(name)
    name = name.succ
    cell
  end
end 
```

```
require "./board"
BOARD
```

将迷宫元素两两联合

```
require "./board"
 
row = BOARD.first
# => [a, b, c, d, e]
 
results = []
row.each_with_index do |cell, i|
  next if i == 0
  results << [row[i-1], cell]
end
 
results
# => [[a, b], [b, c], [c, d], [d, e]]

```

更高级的做法
```
require "./board"
 
row = BOARD.first
# => [a, b, c, d, e]
 
row.each_cons(2).to_a
# => [[a, b], [b, c], [c, d], [d, e]]
```

如果需要将整个二维数组两两联合可以用flat_map(先map， 然后再flat)
```
require "./board"
 
walls = BOARD.flat_map{|row| row.each_cons(2).to_a}.to_a
```


## 317

如果要给迷宫添加外墙， 原来的方式只能给左右相邻的元素添加
如果需要给上下相邻的元素之间添加墙的话

```
require "./board"
 
BOARD
# => [[a, b, c, d, e],
#     [f, g, h, i, j],
#     [k, l, m, n, o],
#     [p, q, r, s, t],
#     [u, v, w, x, y]]
 
BOARD.transpose
# => [[a, f, k, p, u],
#     [b, g, l, q, v],
#     [c, h, m, r, w],
#     [d, i, n, s, x],
#     [e, j, o, t, y]]

latitude_walls = BOARD.transpose.flat_map{|row| row.each_cons(2).to_a}.to_a
# => [[a, f],
#     [f, k],
#     [k, p],
#     [p, u],
#     [b, g],
#     [g, l],
#     [l, q],
#     [q, v],
#     [c, h],
#     [h, m],
#     [m, r],
#     [r, w],
#     [d, i],
#     [i, n],
#     [n, s],
#     [s, x],
#     [e, j],
#     [j, o],
#     [o, t],
#     [t, y]]
```

## 320 Rerun

When we make a change to a Ruby file in the same directory and then save it, we can watch as rerun terminates the process and then re-runs it.

```
rerun ruby app.rb
rerun -d app,lib # dictory
```

如果命令有自己的参数

```
rerun -- ruby app.rb -p 4000
```

运行后马上结束
```
rerun -x rspec
```

## 321 (没看懂)

https://github.com/ahoward/fattr
``` 
require "fattr"

class GameObject
  def initialize(**attributes)
    attributes.each do |name, value|
      public_send name, value
    end
  end
end

class Item < GameObject
  fattr :name
  fattr :weight, default: 1.0
  fattr :value, default: 1
end

class Weapon < Item
  fattr :attack_value, default: 1
end

class Character < GameObject
  fattr :name
  fattr(:inventory) { [] }
end

```

``` 
require "./character2.rb"

LUCY.inventory_weight           # => 35.0
LUCY.inventory_total_value      # => 128
LUCY.weapons
# => [#<Weapon:0x007f8d8211df20
#      @attack_value=12,
#      @name="A Clown Hammer of Smiting",
#      @value=20,
#      @weight=15.0>,
#     #<Weapon:0x007f8d8211dc78
#      @attack_value=37,
#      @name="The Plunger of Dalek",
#      @value=100,
#      @weight=8.0>]
LUCY.strongest_weapon
# => #<Weapon:0x007f8d8211dc78
#     @attack_value=37,
#     @name="The Plunger of Dalek",
#     @value=100,
#     @weight=8.0>

```

```
```

## 322 Benchmark

```
start_time = Time.now
1_000_000.times do
  2 + 2
end
result = Time.now - start_time
result                          # => 0.041977537
```

```
require "benchmark"

result = Benchmark.measure {
  1_000_000.times do
    2 + 1
  end
}
result
# => #<Benchmark::Tms:0x007fe36b90b400
#     @cstime=0.0,
#     @cutime=0.0,
#     @label="",
#     @real=0.044379808,
#     @stime=0.0,
#     @total=0.04000000000000001,
#     @utime=0.04000000000000001>

result.real                     # => 0.043051687 cpu running time
result.stime                    # => 0.0
result.utime                    # => 0.05
result.total                    # => 0.05 procedure running time(may be cpu doing some other work)
```

占用系统时间的例子
```
require "benchmark"

result = Benchmark.measure do
  100_000.times do
    str = "Supercalifragilisticexpialidocious"
    str.reverse!
    File.write("word.txt", str)
  end
end
result.utime                    # => 1.14
result.stime                    # => 4.37
```


## 367  Logs and signals

如何能够动态的切换日志输出级别， 而不用重启server
通过unix的signals，但是SIGINT or SIGTERM已经被用了，我们只能用SIGUSR1 and SIGUSR2

```
require "pastel"
require "logger"

pastel = Pastel.new
colors = {
  "FATAL" => pastel.red.bold.detach,
  "ERROR" => pastel.red.detach,
  "WARN"  => pastel.yellow.detach,
  "INFO"  => pastel.green.detach,
  "DEBUG" => pastel.white.detach,
}

color_formatter = ->(severity, datetime, progname, message) {
  colorizer = $stdout.tty? ? colors[severity] : ->(s){s}
  "#{$$}-#{colorizer.(severity)}: #{message}\n"
}

logger = Logger.new($stderr)
logger.level = Logger::INFO
logger.formatter = color_formatter

loop do
  sleep 0.5
  logger.error "nureek"
  sleep 0.5
  logger.info "retut"
  sleep 0.5
  logger.debug "squrlookal"
  sleep 0.5
  logger.info "hanunga"
end
```

```
trap("USR1") do
  if logger.level == Logger::DEBUG
    logger.level = Logger::ERROR
  else
    logger.level = Logger::DEBUG
  end
end
```

```
ruby "starbug.rb"
```

## 368 Dig

```
require "json"

forecast = JSON.parse(File.read("forecast.json"))

forecast["list"][39]["main"]["temp_min"]
# => 284.37

forecast["list"][40]["main"]["temp_min"]
# =>
# ~> NoMethodError
# ~> undefined method `[]' for nil:NilClass
# ~>
# ~> xmptmp-in25552U3h.rb:8:in `<main>'
```


```
require "json"

forecast = JSON.parse(File.read("forecast.json"))

forecast["list"][40]["main"]["temp_min"] rescue nil
# => nil




!!!NEVER DO THIS
```




Better way

```
require "json"

forecast = JSON.parse(File.read("forecast.json"))

forecast.fetch("list", [])
  .fetch(40, {})
  .fetch("main", {})
  .fetch("temp_min", nil)
# => nil
```














Best Way(array, hash, struct)

```
forecast = JSON.parse(File.read("forecast.json"))
forecast.dig("list", 39, "main", "temp_min")
# => 284.37
forecast.dig("list", 40, "main", "temp_min")
# => nil
```

```
b = %w(pear  banana)
b[2] = %w(apple lemon)
# => ["pear", "banana", ["apple", "lemon"]]
b.dig(2, 1)
b.diga(2, 1)
```

```
c = {a: [1, 2], "b" => [3, 4], c: 5}
c.dig(b, 1)
```

```
Faves = Struct.new(:color, :fruits, :number)
myfaves = Faves.new("pink", %w[apple pear banana], 23)
myfaves.dig("fruits", 2)        # => "banana"
```

## Dig Implementation

```
module Diggable
  def dig(*segments)
  end

  refine Array do
    include Diggable
  end

  refine Hash do
    include Diggable
  end

  refine Struct do
    include Diggable
  end
end
```

```
module Diggable
  def diga(*segments)
    object = self
    while segments.any?
      current_segment, *segments = segments

      if object.respond_to?(:diga)
        return object.diga(*segments)
      elsif object.respond_to?(:[])
        object = object[current_segment]
      else
        return nil
      end
    end
    object
  end

  refine Array do
    include Diggable
  end

  refine Hash do
    include Diggable
  end

  refine Struct do
    include Diggable
  end
end


a = %w(pear  banana)
a[2] = %w(apple lemon)

def a.dig(*segments)
  object = self
  p object
  while segments.any?
    current_segment, *segments = segments
    if object.respond_to?(:dig)
      return object.dig(*segments)
    elsif object.respond_to?(:[])
      object = object[current_segment]
    else
      return nil
    end
  end
  object
end
```

## 375  Named Capture

```
# 以3个数字开头， 多个包含-或字母， 并以3-4个字母结尾
patt = /\A\d{3}-[\w-]+\.\w{3,4}\z/
patt =~ "375-named-capture.mp4" # => 0
patt =~ "vo.wav"                # => nil

# 如果加上group
patt = /\A(\d{3})-([\w-]+)\.(\w{3,4})\z/
patt =~ "375-named-capture.mp4" # => 0
$1                              # => "375"
$2                              # => "named-capture"
$3                              # => "mp4"

# 或者可以用match方法
$~[1]                           # => "375"
Regexp.last_match[2]            # => "named-capture"

md = patt.match("375-named-capture.mp4") # => #<MatchData "375-named-capture....
md[3]                           # => "mp4"
md.captures
# => ["375", "named-capture", "mp4"]

# 但是这样还是不够清楚， 我们必须知道哪个数字对应哪一组匹配
# 我们可以用命名捕获
patt = /\A(?<num>\d{3})-(?<name>[\w-]+)\.(?<ext>\w{3,4})\z/
filename = "375-named-capture.mp4"
patt =~ filename                # => 0
$~[:num]                        # => "375"

Regexp.last_match[:name]        # => "named-capture"
md = patt.match(filename)       # => #<MatchData "375-named-capture.mp4" num:...
md[:ext]                        # => "mp4"
```

## 376 Arrays To Hashes

```
patt = /\A(?<num>\d{3})-(?<name>[\w-]+)\.(?<ext>\w{3,4})\z/
filename = "375-named-capture.mp4"
md = patt.match(filename)       # => #<MatchData "375-named-capture.mp4" num:...
md.names                        # => ["num", "name", "ext"]
md.captures                     # => ["375", "named-capture", "mp4"]

# 两个数组是不是很讨厌， 为什么不提供一个hash的方法呢？
# 如何将数组转换为类hash呢？

# 1. 通过二维数组
names  = ["num", "name", "ext"]
values = ["375", "named-capture", "mp4"]
zipped = names.zip(values)
# => [["num", "375"], ["name", "named-capture"], ["ext", "mp4"]]

zipped.assoc("ext")             # => ["ext", "mp4"]

# 2. 通过reduce
zipped.reduce({}){|result, pair|
  name, value = pair
  result.merge(name => value)
}

zipped.reduce({}){|result, (name, value)|
  result.merge(name => value)
}
zipped.reduce({}){|result, (name, value)|
  result[name] = value
  result
}

# 解决必须返回result的问题
zipped.each_with_object({}) do |(name, value), result|
  result[name] = value
end

# < ruby2.0
Hash[zipped]
# >= ruby2.0
zipped.to_h

# 所以最简洁的做法：
patt = /\A(?<num>\d{3})-(?<name>[\w-]+)\.(?<ext>\w{3,4})\z/
filename = "375-named-capture.mp4"
md = patt.match(filename)       # => #<MatchData "375-named-capture.mp4" num:...
md.names.zip(md.captures).to_h
```


# 377 Chunk While

```
# 如果对这组日志按照时间分组呢， 每条日志间隔小于1就分为一组
I, [2015-12-28T16:13:36.225741 #12345]  INFO -- : Cat belled
I, [2015-12-28T16:13:36.581504 #12345]  INFO -- : Pipes flushed
I, [2015-12-28T16:13:37.181864 #12345]  INFO -- : Steam buckets empty
I, [2015-12-28T16:13:37.319839 #12345]  INFO -- : Cream whipped
I, [2015-12-28T16:13:51.923681 #12345]  INFO -- : Pipes flushed
I, [2015-12-28T16:13:52.016141 #12345]  INFO -- : Cream whipped
I, [2015-12-28T16:13:52.851744 #12345]  INFO -- : Entropy reversed
I, [2015-12-28T16:13:53.014513 #12345]  INFO -- : Wood chucked
I, [2015-12-28T16:13:53.544517 #12345]  INFO -- : Steam buckets empty
I, [2015-12-28T16:15:52.070590 #12345]  INFO -- : Entropy reversed
I, [2015-12-28T16:15:52.519846 #12345]  INFO -- : Stars lighted
I, [2015-12-28T16:15:53.327443 #12345]  INFO -- : Bacon chunked
I, [2015-12-28T16:15:53.746008 #12345]  INFO -- : Pillows plumped
I, [2015-12-28T16:16:44.241876 #12345]  INFO -- : Lemons juiced
I, [2015-12-28T16:16:44.867397 #12345]  INFO -- : Stars lighted
I, [2015-12-28T16:16:45.629143 #12345]  INFO -- : Entropy reversed
I, [2015-12-28T16:16:46.556990 #12345]  INFO -- : Steam buckets empty
I, [2015-12-28T16:16:47.453171 #12345]  INFO -- : Pillows plumped
I, [2015-12-28T16:17:06.726179 #12345]  INFO -- : Pillows plumped
I, [2015-12-28T16:17:06.816256 #12345]  INFO -- : Wood chucked
I, [2015-12-28T16:17:07.774405 #12345]  INFO -- : Cream whipped
I, [2015-12-28T16:17:47.759721 #12345]  INFO -- : Bacon chunked
I, [2015-12-28T16:17:48.463404 #12345]  INFO -- : Pipes flushed
I, [2015-12-28T16:17:48.702728 #12345]  INFO -- : Wood chucked

# chunk_while方法
a = [1,2,4,9,10,11,12,15,16,19,20,21]
b = a.chunk_while {|i, j| i+1 == j }
p b.to_a #=> [[1, 2], [4], [9, 10, 11, 12], [15, 16], [19, 20, 21]]

require "time"
entries = File.readlines("events.log")
chunks = entries.chunk_while{|entry_before, entry_after|
  timestamp_before = Time.parse(entry_before[4..29])
  timestamp_after  = Time.parse(entry_after[4..29])
  timestamp_after - timestamp_before < 1.0
}

chunks.each do |chunk|
  puts *chunk
  puts
end

# >> I, [2015-12-28T16:13:36.225741 #12345]  INFO -- : Cat belled
# >> I, [2015-12-28T16:13:36.581504 #12345]  INFO -- : Pipes flushed
# >> I, [2015-12-28T16:13:37.181864 #12345]  INFO -- : Steam buckets empty
# >> I, [2015-12-28T16:13:37.319839 #12345]  INFO -- : Cream whipped
# >>
# >> I, [2015-12-28T16:13:51.923681 #12345]  INFO -- : Pipes flushed
# >> I, [2015-12-28T16:13:52.016141 #12345]  INFO -- : Cream whipped
# >> I, [2015-12-28T16:13:52.851744 #12345]  INFO -- : Entropy reversed
# >> I, [2015-12-28T16:13:53.014513 #12345]  INFO -- : Wood chucked
# >> I, [2015-12-28T16:13:53.544517 #12345]  INFO -- : Steam buckets empty
# >>
# >> I, [2015-12-28T16:15:52.070590 #12345]  INFO -- : Entropy reversed
# >> I, [2015-12-28T16:15:52.519846 #12345]  INFO -- : Stars lighted
# >> I, [2015-12-28T16:15:53.327443 #12345]  INFO -- : Bacon chunked
# >> I, [2015-12-28T16:15:53.746008 #12345]  INFO -- : Pillows plumped
# >>
# >> I, [2015-12-28T16:16:44.241876 #12345]  INFO -- : Lemons juiced
# >> I, [2015-12-28T16:16:44.867397 #12345]  INFO -- : Stars lighted
# >> I, [2015-12-28T16:16:45.629143 #12345]  INFO -- : Entropy reversed
# >> I, [2015-12-28T16:16:46.556990 #12345]  INFO -- : Steam buckets empty
# >> I, [2015-12-28T16:16:47.453171 #12345]  INFO -- : Pillows plumped
# >>
# >> I, [2015-12-28T16:17:06.726179 #12345]  INFO -- : Pillows plumped
# >> I, [2015-12-28T16:17:06.816256 #12345]  INFO -- : Wood chucked
# >> I, [2015-12-28T16:17:07.774405 #12345]  INFO -- : Cream whipped
# >>
# >> I, [2015-12-28T16:17:47.759721 #12345]  INFO -- : Bacon chunked
# >> I, [2015-12-28T16:17:48.463404 #12345]  INFO -- : Pipes flushed
# >> I, [2015-12-28T16:17:48.702728 #12345]  INFO -- : Wood chucked
# >> I, [2015-12-28T16:17:49.519692 #12345]  INFO -- : Steam buckets empty
# >> I, [2015-12-28T16:17:49.946548 #12345]  INFO -- : Cat belled
# >>
# >> I, [2015-12-28T16:18:17.362492 #12345]  INFO -- : Lemons juiced
# >> I, [2015-12-28T16:18:17.891629 #12345]  INFO -- : Entropy reversed
# >> I, [2015-12-28T16:18:18.658450 #12345]  INFO -- : Steam buckets empty
# >>
# >> I, [2015-12-28T16:18:50.696795 #12345]  INFO -- : Wood chucked
# >> I, [2015-12-28T16:18:51.322421 #12345]  INFO -- : Steam buckets empty
# >> I, [2015-12-28T16:18:51.704837 #12345]  INFO -- : Bacon chunked
# >> I, [2015-12-28T16:18:52.067990 #12345]  INFO -- : Stars lighted
# >>
```

## 378 Fetch Values

```
假设有三种配置， 我们如何能将所有的配置合成一个呢?
keys = %i[system_prefs user_prefs project_prefs]
configuration = {
  system_prefs:       { font: "Ubuntu Mono", text_color: "wheat" },
  user_prefs:         { font: "Source Code Pro" },
  project_prefs:      { error_color: "brick" }
}


prefs_cascade = configuration.values_at(*keys)

prefs = prefs_cascade.reduce{|result, prefs|
  result.merge(prefs)
}
# 更简洁一点：prefs = prefs_cascade.reduce(&:merge)

# 但是如果某一个配置没有呢？
configuration = {
  system_prefs:       { font: "Ubuntu Mono", text_color: "wheat" },
  # user_prefs:         { font: "Source Code Pro" },
  project_prefs:      { error_color: "brick" }
}
prefs_cascade = configuration.values_at(*keys)
prefs = prefs_cascade.reduce(&:merge)
# ERROR 我们需要排除掉nil
prefs_cascade.compact!

# 但是这种做法是不推荐的， 我们应该从源头去检查nil出现的原因， 而不是堵这个漏洞

prefs_cascade = configuration.fetch_values(*keys)
prefs_cascade = configuration.fetch_values(*keys){ {} }


# 如果我们要设置默认值呢？
DEFAULTS = {
  project_prefs:      {},
  user_prefs:         {},
  system_prefs: { font: "monospace", text_color: "white", error_color: "red" }
}
configuration = {
  # system_prefs:       { font: "Ubuntu Mono", text_color: "wheat" },
  user_prefs:         { font: "Source Code Pro" },
  project_prefs:      { error_color: "brick" }
}
prefs_cascade = configuration.fetch_values(*keys) { |key|
  DEFAULTS[key]
}


# 从ruby2.3开始， 我们能直接将hash转成proc
prefs_cascade = configuration.fetch_values(*keys, &DEFAULTS)
```

## 385 Error 127

```ruby
file "source.html" => "source.rb" do
  sh "pigmentize -o source.html source.rb"
end

```

```bash
$ rake source.html

pigmentize -o source.html source.rb
rake aborted!
Command failed with status (127): [pigmentize -o source.html source.rb...]
/home/avdi/Dropbox/rubytapas/385-error-127/Rakefile:3:in `block in <top (require
d)>'
Tasks: TOP => source.html
(See full trace by running task with --trace)
```

```ruby
# 成功返回true, 失败返回false， 返回nil证明执行过程中失败了
system "pigmentize -o source.html source.rb"
# => nil
```

```ruby
system "pigmentize -o source.html source.rb"
$? # => #<Process::Status: pid 5386 exit 127>
$?.exitstatus                   # => 127
```

```bash
$ pigmentize -o source.html source.rb
No command 'pigmentize' found, did you mean:
 Command 'pygmentize' from package 'python-pygments' (main)
pigmentize: command not found

$ echo $?
127
```

## 386 Error

```
# 打开一个不存在的文件的时候
open("NOTEXIST")
# =>

# ~> Errno::ENOENT
# ~> No such file or directory @ rb_sysopen - NOTEXIST
# ~>
# ~> xmptmp-in7940Ca2.rb:1:in `initialize'
# ~> xmptmp-in7940Ca2.rb:1:in `open'
# ~> xmptmp-in7940Ca2.rb:1:in `<main>'
```

```
明明是Errno， 如何查看错误number
Errno::ENOENT::Errno            # => 2

但是这些错误在不同的机器上也是不同的
Errno::EDOOFUS::Errno           # => 0(macox)
Errno::EDOOFUS::Errno           # => 88(freeebsd)

如果我们想知道错误的具体信息而不用等错误抛出才知道呢？
如果是c语言， 通过`strerror()`是可以知道的， 但是Ruby下面很麻烦
SystemCallError.new(2).message
```

## 387 Fiddle

```
# 这种方法可行， 是因为当我们调用的时候， ruby会向操作系统询问这个编码
# 所代表的错误信息，然后再返回给我们
SystemCallError.new(2).message

# 那么为什么我们不能直接询问操作系统呢？因为ruby没有提供api
# 我们可以通过标准库Fiddle来直接访问动态加载的c类库
require "fiddle"

libc = Fiddle.dlopen(nil)
libc["strerror"]
# => 139997737567408

# ?有办法可以知道ruby方法所需要的参数类型吗？

strerror = Fiddle::Function.new(
  libc['strerror'], # 载入的标准库代码
  [Fiddle::TYPE_INT], # 参数类型
  Fiddle::TYPE_VOIDP) # 返回值
# => #<Fiddle::Function:0x00562ef8840760 @ptr=140662671672496, @args=[4], @re...

ptr = strerror.call(2)          # => #<Fiddle::Pointer:0x00562ef8953330 ptr=0...
ptr.to_s                        # => "No such file or directory"

# 我们可以省略call，直接用.来代替
strerror.(2).to_s
# => "No such file or directory"
strerror.(3).to_s
# => "No such process"
strerror.(4).to_s
# => "Interrupted system call"
```


## 394 Consistency

```
STOP_WORDS = %w[in the of]

# Block #1
input = %w"When in the course of human events"
output = []
while word = input.shift
  unless STOP_WORDS.include?(word.downcase)
    output << word
  end
end
output
# => ["When", "course", "human", "events"]

# Block #2
input = %w"When in the course of human events"
output = input.map(&:downcase) - STOP_WORDS
output
# => ["when", "course", "human", "events"]
```

保持编码风格的一致性， 能够使问题暴露的更明显
但是我并没有觉得下面的代码更容易暴露问题， 只是编码上风格更一致了

```
# Block #2
input = %w"When in the course of human events"
output = input.map(&:downcase) - STOP_WORDS
input
# => ["When", "in", "the", "course", "of", "human", "events"]
output
# => ["when", "course", "human", "events"]

# Block #3
input = %w"When in the course of human events"
output = input.shift(input.size).reject{|w| STOP_WORDS.include?(w.downcase)}
input
# => []
output
# => ["When", "course", "human", "events"]
```

## 395 Microconcerns

To ensure the max of age is 50
```
class Cheese
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def age
    @value += increment if value < 50
  end

  private

  def increment
    1
  end
end

class GreenCheese < Cheese
  private
  def increment
    2
  end
end
```

The problem is:

```
gc = GreenCheese.new(49)
gc.age
gc.value                        # => 51
```

Solve the problem:

```
def age
  adjusted_increment = [increment, 50-value].min
  @value += adjusted_increment if value < 50
end
```

Separate concern:

```
def age
  @value += increment
  @value = [@value, 50].min
end

furter:

def age
  increment_value
  constrain_value
end

def increment_value
  @value += increment
end

def constrain_value
  @value = [@value, 50].min
end
```

## 396 Invariant

```
class Cheese
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def age
    increment_value
    @value                      # => 51
    constrain_value
  end

  private

  def increment_value
    @value += increment
  end

  def constrain_value
    @value = [@value, 50].min
  end

  def increment
    1
  end
end

This means that between when a public method is called, and when it returns, the object can spend some time in an inconsistent state, and no invariants will be violated.
```

```
class Cheese
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def age
    new_value = increment_value(value)
    new_value = constrain_value(new_value)
    @value = new_value
  end

  private

  def increment_value(value)
    value + increment
  end

  def constrain_value(value)
    [value, 50].min
  end

  def increment
    1
  end
end

I especially like code where I can remove a concern or move a concern just by removing or moving a line, without any other touch-up needed
```

## 406 last match

format from this
```
shodan: INFO Mining laser maintenance cycle finished
shodan: INFO Reactor nominal
shodan: WARN Unverified access
shodan: INFO Grove climate control day cycle
shodan: WARN Ethics node offline
shodan: ERROR Notification of station IT failed
shodan: INFO Science level security protocols updated
shodan: ERROR Uncontrolled neural net reconfiguration
shodan: ERROR Safety protocols inconsistent with updated mandates
shodan: FATAL Logging subsystem compromi
```
to this:

```
* Notification of station IT failed
* Uncontrolled neural net reconfiguration
* Safety protocols inconsistent with updated mandates
! Logging subsystem compromi
```

step 1
```
sigils = { "ERROR" => "*", "FATAL" => "!", "WARN" => "?" }
output = open("shodan.log").each_line.grep(/ERROR|FATAL/).map{|line|
  level   = line[/ERROR|FATAL/]
  message = line[/(ERROR|FATAL) (.*)/, 2]
  "#{sigils[level]} #{message}"
}
```

step 2
```
sigils = { "ERROR" => "*", "FATAL" => "!", "WARN" => "?" }
output = open("shodan.log").each_line.grep(/ERROR|FATAL/) {|line|
  level   = line[/ERROR|FATAL/]
  message = line[/(ERROR|FATAL) (.*)/, 2]
  "#{sigils[level]} #{message}"
}
```
step 3
```
sigils = { "ERROR" => "*", "FATAL" => "!", "WARN" => "?" }
output = open("shodan.log").each_line.grep(/ERROR|FATAL/) {|line|
  match   = line.match(/(ERROR|FATAL) (.*)/)
  level   = match[1]
  message = match[2]
  "#{sigils[level]} #{message}"
}
```

step 4
```
sigils = { "ERROR" => "*", "FATAL" => "!", "WARN" => "?" }
output = open("shodan.log").each_line.grep(/(ERROR|FATAL) (.*)/) {|line|
  #<MatchData "ERROR Notification of station IT failed" 1:"ERROR" 2:"Notification of station IT failed">
  match   = Regexp.last_match
  # "ERROR"
  level   = match[1]
  "Notification of station IT failed"
  message = match[2]
  "#{sigils[level]} #{message}"
}
```

step 5
```
sigils = { "ERROR" => "*", "FATAL" => "!", "WARN" => "?" }
output = open("shodan.log").each_line.grep(/ERROR|FATAL/) {|line|
  # "ERROR"
  level   = Regexp.last_match.to_s
  # "Notification of station IT failed"
  message = Regexp.last_match.post_match.strip
  "#{sigils[level]} #{message}"
}
```

step 6
```
match = Regexp.last_match         # => #<MatchData "ERROR">
$~                                # => #<MatchData "ERROR">
match.pre_match                   # => "shodan: "
$`                                # => "shodan: "
match.to_s                        # => "ERROR"
$&                                # => "ERROR"
match.post_match                  # => " Notification of station IT failed"
$'                                # => " Notification of station IT failed"

sigils = { "ERROR" => "*", "FATAL" => "!", "WARN" => "?" }
output = open("shodan.log").each_line.grep(/ERROR|FATAL/) {|line|
  "#{sigils[$&]} #{$'.strip}"
}
```

## Primitive Obsession

```
class Course
    attr_accessor :title, :duration

    def initialize(title: title, duration: duration)
      @title      = title
      @duration   = duration
    end

    def duration_in_months
      @duration / 28
    end

    def duration_in_weeks
      @duration / 7
    end

    def duration_in_days
      @duration
    end
  end

COURSES = {
  potions: Course.new(title: "Potions 101", duration: 90),
  scrying: Course.new(title: "Scrying 101", duration: 21),
  hexes: Course.new(title: "Hexes", duration: 3),
}
```

```
render_course_info(COURSES[:hexes])
# => "Hexes (3 days)"
render_course_info(COURSES[:potions])
# => "Potions 101 (3 months)"

def render_course_info(course)
  "#{course.title} (#{render_course_duration(course)})"
end

def render_course_duration(course)
  if course.duration < 14
    "#{course.duration_in_days} days"
  elsif course.duration_in_days < 60
    "#{course.duration_in_weeks} weeks"
  else
    "#{course.duration_in_months} months"
  end
end
```

## Whole Value

```
class Duration
  def self.[](count)
    self.new(count)
  end

  attr_reader :magnitude

  def initialize(magnitude)
    @magnitude = magnitude
    freeze
  end

  def inspect
    "#{self.class}[#{magnitude}]"
  end

  def to_s
    "#{magnitude} #{self.class.name.downcase}"
  end

  alias_method :to_i, :magnitude
end

class Days < Duration; end
class Weeks < Duration; end
class Months < Duration; end

# Months[2], Weeks[3]

class Course
  attr_accessor :title, :duration

  def initialize(title: title, duration: duration)
    @title      = title
    @duration   = duration
  end
end

COURSES = {
  potions: Course.new(title: "Potions 101", duration: Months[3]),
  scrying: Course.new(title: "Scrying 101", duration: Weeks[3]),
  hexes: Course.new(title: "Hexes", duration: Days[3]),
}

def render_course_info(course)
  "#{course.title} (#{course.duration})"
end

render_course_info(COURSES[:hexes])
# => "Hexes (3 days)"
render_course_info(COURSES[:potions])
# => "Potions 101 (3 months)"
```

2016-4-20
========

:authenticity_token
http://stackoverflow.com/questions/941594/understanding-the-rails-authenticity-token#comment16039314_1571900
http://stackoverflow.com/questions/9996665/rails-how-does-csrf-meta-tag-work

2016-4-17
========

:string :template 194, 195, 196
:decorator ::197::198::

2016-4-8
========

:lazy-loader-191

2016-4-3
========

:sort-181

当你对数组进行排序， 而排序的值是需要计算的时候， 采用sort_by比sort的效率要高很多.
因为sort每次比较都会重新计算你排序的值， 而sort_by则会先计算所有的值并保存， 用于下一次的比较

:macro-182-183

2016-4-2
========

:aliasing-177-178

:lazy-load-174-180


2016-3-29
=========

:puts

puts => "put string", 当我们使用puts的时候， puts会自动给每一行的输出
加上换行符（多线程下会出问题， 需要给字符串手动加上换行符）; puts 接受
多个字符串参数， 每个单独打印成一行

:for, :each

for和each的差别就在于for没有自己的作用域， 变量的修改会作用到变量本省，
一个常见的问题就是循环的时候， 修改了循环计数的值。

```
for n in n.downto(1)
  puts n
end
puts "#{n}" #=> 1, if you use each, here shows 4
```
