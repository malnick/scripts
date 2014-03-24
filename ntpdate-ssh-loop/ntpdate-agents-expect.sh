#!/usr/bin/expect -f

set ip_file "list.txt"
set fid [open $ip_file r]

while {[gets $fid ip] != -1} {

    spawn ssh $ip -l admin
    expect "Password:"
    send "password\r"

    expect "admin@"
    send "set cli pager off\r"

    log_file $logfile
    send "show config running\r"

    expect "admin@"
    log_file 

    send "exit\r"
    expect eof

}
close $fid
