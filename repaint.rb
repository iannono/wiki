require "fileutils"
$animation = %w[| / - \\ | / - \\]
def repaint(pids, start_time)
  print "\e[H\e[2J"
  elapsed = Time.now - start_time
  mins, secs = elapsed.to_i.divmod(60)
  printf "Transcoding... %s %02d:%02d\n\n", $animation.rotate!.first, mins, secs
  template = "%-10s%s\n"
  header   = template % ["PID", "Time"]
  print header
  puts "-" * header.size
  pids.each do |pid, status|
    printf template, pid, status.to_s.upcase
  end
end

pids = {}

trap("CHLD") do
  while pids.values.include?(:working) &&
    pid = Process.waitpid(-1, Process::WNOHANG)
    pids[pid] = :done
  end
end 
 
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
 
repaint(pids, start_time)
