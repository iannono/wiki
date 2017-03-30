2016-9-11
=========

## 自动重启脚本

```
#!bin/bash

cd /home/deploy/app/feedmob_tracking/current
if [ `ps auxw | grep unicorn | grep -v grep | wc -l` -eq '0' ]
then
  if [ -f "/home/techbay/app/feedmob_tracking/shared/tmp/pids/unicorn.feedmob_tracking.pid" ]; then
    rm /home/techbay/app/feedmob_tracking/shared/tmp/pids/unicorn.feedmob_tracking.pid
  fi
  /home/deploy/.rbenv/shims/bundle exec unicorn_rails -c /home/deploy/app/feedmob_tracking/current/config/unicorn.rb -E production -D
  echo "-----------start unicorn at `date`-------------"
fi
```

## linux 脚本监控
http://www.bkjia.com/jcjc/1108784.html

监控硬件运行状况

shell 监控cpu，memory，load average，记录到log，当负载压力时，发电邮通知管理员。
原理：
1.获取cpu，memory，load average的数值
2.判断数值是否超过自定义的范围，例如（CPU>90%，Memory<10%，load average>2）
3.如数值超过范围，发送电邮通知管理员。发送有时间间隔，每小时只会发送一次。
4.将数值写入log。
5.设置crontab 每30秒运行一次。

```
#!/bin/bash 
 
# 系统监控,记录cpu、memory、load average,当超过规定数值时发电邮通知管理员 
 
# *** config start *** 
 
# 当前目录路径 
ROOT=$(cd "$(dirname "$0")"; pwd) 
 
# 当前服务器名 
HOST=$(hostname) 
 
# log 文件路径 
CPU_LOG="${ROOT}/logs/cpu.log" 
MEM_LOG="${ROOT}/logs/mem.log" 
LOAD_LOG="${ROOT}/logs/load.log" 
 
# 通知电邮列表 
NOTICE_EMAIL='admin@admin.com' 
 
# cpu,memory,load average 记录上一次发送通知电邮时间 
CPU_REMARK='/tmp/servermonitor_cpu.remark' 
MEM_REMARK='/tmp/servermonitor_mem.remark' 
LOAD_REMARK='/tmp/servermonitor_loadaverage.remark' 
 
# 发通知电邮间隔时间 
REMARK_EXPIRE=3600 
NOW=$(date +%s) 
 
# *** config end *** 
 
 
# *** function start *** 
 
# 获取CPU占用 
function GetCpu() { 
  cpufree=$(vmstat 1 5 |sed -n '3,$p' |awk '{x = x + $15} END {print x/5}' |awk -F. '{print $1}') 
  cpuused=$((100 - $cpufree)) 
  echo $cpuused 
 
  local remark 
  remark=$(GetRemark ${CPU_REMARK}) 
 
  # 检查CPU占用是否超过90% 
  if [ "$remark" = "" ] && [ "$cpuused" -gt 90 ]; then 
    echo "Subject: ${HOST} CPU uses more than 90% $(date +%Y-%m-%d' '%H:%M:%S)" | sendmail ${NOTICE_EMAIL} 
    echo "$(date +%s)" > "$CPU_REMARK" 
  fi 
} 
 
# 获取内存使用情况 
function GetMem() { 
  mem=$(free -m | sed -n '3,3p') 
  used=$(echo $mem | awk -F ' ' '{print $3}') 
  free=$(echo $mem | awk -F ' ' '{print $4}') 
  total=$(($used + $free)) 
  limit=$(($total/10)) 
  echo "${total} ${used} ${free}" 
 
  local remark 
  remark=$(GetRemark ${MEM_REMARK}) 
 
  # 检查内存占用是否超过90% 
  if [ "$remark" = "" ] && [ "$limit" -gt "$free" ]; then 
    echo "Subject: ${HOST} Memory uses more than 90% $(date +%Y-%m-%d' '%H:%M:%S)" | sendmail ${NOTICE_EMAIL} 
    echo "$(date +%s)" > "$MEM_REMARK" 
  fi 
} 
 
# 获取load average 
function GetLoad() { 
  load=$(uptime | awk -F 'load average: ' '{print $2}') 
  m1=$(echo $load | awk -F ', ' '{print $1}') 
  m5=$(echo $load | awk -F ', ' '{print $2}') 
  m15=$(echo $load | awk -F ', ' '{print $3}') 
  echo "${m1} ${m5} ${m15}" 
 
  m1u=$(echo $m1 | awk -F '.' '{print $1}') 
 
  local remark 
  remark=$(GetRemark ${LOAD_REMARK}) 
 
  # 检查是否负载是否有压力 
  if [ "$remark" = "" ] && [ "$m1u" -gt "2" ]; then 
    echo "Subject: ${HOST} Load Average more than 2 $(date +%Y-%m-%d' '%H:%M:%S)" | sendmail ${NOTICE_EMAIL} 
    echo "$(date +%s)" > "$LOAD_REMARK" 
  fi 
} 
 
# 获取上一次发送电邮时间 
function GetRemark() { 
  local remark 
 
  if [ -f "$1" ] && [ -s "$1" ]; then 
    remark=$(cat $1) 
 
    if [ $(( $NOW - $remark )) -gt "$REMARK_EXPIRE" ]; then 
      rm -f $1 
      remark="" 
    fi 
  else 
    remark="" 
  fi 
 
  echo $remark 
} 
 
 
# *** function end *** 
 
cpuinfo=$(GetCpu) 
meminfo=$(GetMem) 
loadinfo=$(GetLoad) 
 
echo "cpu: ${cpuinfo}" >> "${CPU_LOG}" 
echo "mem: ${meminfo}" >> "${MEM_LOG}" 
echo "load: ${loadinfo}" >> "${LOAD_LOG}" 
 
exit 0 
```

监控网站是否异常 
shell 监控网站是否异常的脚本，如有异常自动发电邮通知管理员。
流程：
1.检查网站返回的http_code是否等于200，如不是200视为异常。
2.检查网站的访问时间，超过MAXLOADTIME（10秒）视为异常。
3.发送通知电邮后，在/tmp/monitor_load.remark记录发送时间，在一小时内不重复发送，如一小时后则清空/tmp/monitor_load.remark。

ServerMonitor.sh 

```
#!/bin/bash 
 
SITES=("http://web01.example.com" "http://web02.example.com") # 要监控的网站 
NOTICE_EMAIL='me@example.com'                 # 管理员电邮 
MAXLOADTIME=10                        # 访问超时时间设置 
REMARKFILE='/tmp/monitor_load.remark'             # 记录时否发送过通知电邮，如发送过则一小时内不再发送 
ISSEND=0                           # 是否有发送电邮 
EXPIRE=3600                          # 每次发送电邮的间隔秒数 
NOW=$(date +%s) 
 
if [ -f "$REMARKFILE" ] && [ -s "$REMARKFILE" ]; then 
  REMARK=$(cat $REMARKFILE) 
   
  # 删除过期的电邮发送时间记录文件 
  if [ $(( $NOW - $REMARK )) -gt "$EXPIRE" ]; then 
    rm -f ${REMARKFILE} 
    REMARK="" 
  fi 
else 
  REMARK="" 
fi 
 
# 循环判断每个site 
for site in ${SITES[*]}; do 
 
  printf "start to load ${site}\n" 
  site_load_time=$(curl -o /dev/null -s -w "time_connect: %{time_connect}\ntime_starttransfer: %{time_starttransfer}\ntime_total: %{time_total}" "${site}") 
  site_access=$(curl -o /dev/null -s -w %{http_code} "${site}") 
  time_total=${site_load_time##*:} 
 
  printf "$(date '+%Y-%m-%d %H:%M:%S')\n" 
  printf "site load time\n${site_load_time}\n" 
  printf "site access:${site_access}\n\n" 
 
  # not send 
  if [ "$REMARK" = "" ]; then 
    # check access 
    if [ "$time_total" = "0.000" ] || [ "$site_access" != "200" ]; then 
      echo "Subject: ${site} can access $(date +%Y-%m-%d' '%H:%M:%S)" | sendmail ${NOTICE_EMAIL} 
      ISSEND=1 
    else 
      # check load time 
      if [ "${time_total%%.*}" -ge ${MAXLOADTIME} ]; then 
        echo "Subject: ${site} load time total:${time_total} $(date +%Y-%m-%d' '%H:%M:%S)" | sendmail ${NOTICE_EMAIL} 
        ISSEND=1 
      fi 
    fi 
  fi 
 
done 
 
# 发送电邮后记录发送时间 
if [ "$ISSEND" = "1" ]; then 
  echo "$(date +%s)" > $REMARKFILE 
fi 
 
exit 0 
```

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
