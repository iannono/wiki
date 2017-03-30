## Linux Command 学习笔记



### Chapter 2

#### ls 常用选项

-a	--all	列出所有文件，甚至包括文件名以圆点开头的默认会被隐藏的隐藏文件。
-d	--directory	通常，如果指定了目录名，ls 命令会列出这个目录中的内容，而不是目录本身。 把这个选项与 -l 选项结合使用，可以看到所指定目录的详细信息，而不是目录中的内容。
-F	--classify	这个选项会在每个所列出的名字后面加上一个指示符。例如，如果名字是 目录名，则会加上一个'/'字符。
-h	--human-readable	当以长格式列出时，以人们可读的格式，而不是以字节数来显示文件的大小。
-l		以长格式显示结果。
-r	--reverse	以相反的顺序来显示结果。通常，ls 命令的输出结果按照字母升序排列。
-S		命令输出结果按照文件大小来排序。
-t		按照修改时间来排序。

### Chapter 6

type command: 显示命令的类别

which ls: 用于显示可执行程序的位置（不包括内部命令和命令别名）

apropos ruby: 搜索参考列表中基于某个关键字的匹配项

info ruby :显示程序info条目

alias name='string': 用于设置别名， string字符串中的命令使用分号进行分隔（可以将别名写在单独的文件中， 然后载入到bashrc里面？）

unlias name: 用于删除别名

### Chapter 7

`ls -l /usr/bin > ls-output.txt `

将标准输出重定向文件

`> ls-output.txt`

删除文件中已有的内容， 或者新建一个文件

`ls -l /usr/bin >> ls-output.txt`

将结果追加到文件中

`ls -l /bin/usr > ls-output.txt 2>&1； ls -l /bin/usr &> ls-output.txt`

重定向标准输出和标准错误到同一个文件中的两种方式， 后一种更加精简

`ls -l /bin/usr 2> /dev/null`

处理不需要的输出

`cat`

cat命令如果不接受任何参数， 则是接受用户的输入

`cat > lazy_dog.txt； cat < lazy_dog.txt`

通过不带参数的cat命令来将标准输入的内容输出到文件， 也可以通过反向的破则号将文件作为标准输入

`ls /bin /usr/bin | sort | uniq | wc -l`

使用管道在命令间传递数据

`ls /bin /usr/bin | sort | uniq | grep zip`

使用grep过滤匹配数据

`tail -f log.txt； head -n 5 log.txt`

从头和从尾部读取数据

`ls /usr/bin | tee ls.txt | grep zip`

tee命令允许输出到文件的同时还可以继续输出内容到标准输出



### Chapter 12

set 命令可以 显示 shell 和环境变量两者，而 printenv 只是显示环境变量

`printenv | less;`  `printenv USER`







