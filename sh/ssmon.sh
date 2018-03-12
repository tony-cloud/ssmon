#!/bin/sh
####$pid用于追踪重复启动###
pid=$$
pidrun=$(ps | grep ssmon.sh | grep -v grep | grep -v $pid | awk '{print $1}')
####检测是否是第一次启动###
ps | grep ssmon.sh | grep -v grep | grep -v $pid
if test $? -ne 0
then
  logger -t "ssmon: ssmon start，start monitor，PID" $pid
  while :
  do
   ps |grep ss-redir |grep -v grep
    if test $? -ne 0
	then
	    sleep 10
		continue
	else
		iptables -t nat -vL |grep SS_SPEC_LAN_DG |grep Chain |grep -v grep
		if test $? -ne 0
		then
		    sleep 10
			continue
		else
		  
		    iptables -t nat -vL |grep SS_SPEC_LAN_DG |grep any |grep -v grep
		    if test $? -ne 0
			then
			    ps | grep firewall.sh | grep -v grep
                if test $? -ne 0
                then
		    	    nohup /etc/sh/firewall.sh >/dev/null 2>&1 &
			    	logger -t "ssmon: delegate rule lost，re-add. PID" $pid
					sleep 10
				    continue
				else
				   sleep 10
				   continue
				fi
			else
			    iptables -t nat -vL |grep SS_SPEC_LAN_DG |grep any |grep -v all |grep -v grep
		        if test $? -ne 0
		        then
				   sleep 30
				   continue
				else
				   iptables -t nat -D SS_SPEC_WAN_FW -p tcp -j REDIRECT --to-port 1080
				   iptables -t nat -D PREROUTING -p tcp -j SS_SPEC_LAN_DG
			       nohup /etc/sh/firewall.sh >/dev/null 2>&1 &
			       logger -t "ssmon: delegate rules incurrect, re-add. PID" $pid
			       sleep 10
			       continue
				fi
			fi
		fi
	fi
  done
else
	logger -t "ssmon: another ss-mon found. Multi startup detected, stop. Another PID is " $pidrun
	logger -t "ssmon: Nothing to do, bye. PID "$pid
fi

exit 0



