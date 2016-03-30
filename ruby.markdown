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
