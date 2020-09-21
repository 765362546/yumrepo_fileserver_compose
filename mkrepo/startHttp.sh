#!/bin/bash

# 读取定义的变量
CUR=$(cd `dirname $0`;pwd)

start(){
cd ${CUR} && nohup python -m SimpleHTTPServer 80 &>/dev/null &
}
stop(){
ps -ef | egrep "SimpleHTTPServer" | grep -v grep | awk '{print $2}' | xargs kill -9
}
status(){
 P_PID=$(ps -ef | egrep "SimpleHTTPServer" | grep -v grep | awk '{print $2}')
 if [ "X${P_PID}" != "X"  ] ;then
     echo "repo is running"
     for f in `ls centos`;do
         echo "http://xxxx/centos/$f"
     done
     if [ -d third ];then
     echo '' > thrid.txt
     for f in `ls third/`;do
         echo "third/$f" >>thrid.txt 
     done
     fi
 else
     echo "repo is down"
 fi
}
action=$1
case $action in
    start)
        start
        status
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        status
        ;;
    status)
        status
        ;;
    *)
        echo "$0 start|stop|restart|status"
        ;;
esac
