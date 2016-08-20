2016-5-14
=========

## Amazon

扩展硬盘空间
http://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/ebs-expand-volume.html

## Disk usage

du -h /home
want to know directiory
du -sh /home
du -ah /home
du -mh /home
du -ah --exclude="*.txt" /home/tecmint

df -a /
df -h /
df -hT /home
show inode
df -i 

du -b --max-depth 1 | sort -nr | perl -pe 's{([0-9]+)}{sprintf"%.1f%s", $1>=2**30? ($1/2**30, "G"): $1>=2**20? ($1/2**20, "M"):$1>=2**10? ($1/2**10, "K"): ($1, "")}e'

## environment

ctags:

brew install ctags

add to ~/.ctags
```
--recurse=yes
--exclude=.git
--exclude=vendor/*
--exclude=node_modules/*
--exclude=db/*
--exclude=log/*
```
echo "tags" >> ~/.global_ignore
git config --global core.excludesfile $HOME/.global_ignore

## linux edit

移动光标
* `ctrl+b`: 前移一个字符(backward)
* `ctrl+f`: 后移一个字符(forward)
* `alt+b`: 前移一个单词
* `alt+f`: 后移一个单词
* `ctrl+a`: 移到行首（a是首字母） 
* `ctrl+e`: 移到行尾（end）
* `ctrl+x`: 行首到当前光标替换

编辑命令
* `alt+.`: 粘帖最后一次命令最后的参数（通常用于`mkdir long-long-dir`后, `cd`配合着`alt+.`）
* `alt+d`: 删除当前光标到临近右边单词开始(delete)
* `ctrl+w`: 删除当前光标到临近左边单词结束(word)
* `ctrl+h`: 删除光标前一个字符（相当于backspace）
* `ctrl+d`: 删除光标后一个字符（相当于delete）
* `ctrl+u`: 删除光标左边所有
* `ctrl+k`: 删除光标右边所有
* `ctrl+l`: 清屏
* `ctrl+shift+c`: 复制（相当于鼠标左键拖拽）
* `ctrl+shift+v`: 粘贴（相当于鼠标中键）

## neovim

```
ln -s ~/Dropbox/myvim/.nvim ~/.config/nvim
ln -s ~/Dropbox/myvim/.vimrc ~/.config/nvim/init.vim
```

##  当系统报No space left on device 如何解决

```
检查磁盘占用
df -lk

检查inode的占用情况
df -li

删除日志文件
rm -rf /var/log/*
```
