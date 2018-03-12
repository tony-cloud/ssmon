#!/bin/sh
####$pid用于追踪重复启动###
pid=$$
pidrun=$(ps | grep firewall.sh | grep -v grep | grep -v $pid | awk '{print $1}')
####检测是否是第一次启动###
ps | grep firewall.sh | grep -v grep | grep -v $pid
if test $? -ne 0
then
	logger -t "ssmon" "ss-wall not found. First startup detected, continue. PID" $pid
	##开始等待ss-redir启动####
	while :
	do
		sleep 3
		logger -t "ssmon: Waiting for ss-redir to start. PID" $pid
		ps |grep ss-redir |grep -v grep
		if test $? -ne 0
		then
		##没启动就继续等待##    
			logger -t "ssmon ss-redir not running, continue waiting. PID" $pid
			continue
		else
		##检测到启动####检查ss链是否存在
			iptables -t nat -vL |grep SS_SPEC_LAN_DG |grep Chain |grep -v grep
			if test $? -ne 0
			then
			##不存在就继续等待##
			    sleep 10
				continue
			else
			##存在时检测规则是否已经添加##
				iptables -t nat -vL |grep SS_SPEC_LAN_DG |grep tcp |grep -v grep
				if test $? -ne 0
				then
				    iptables -t nat -vL |grep delegate_pre |grep Chain |grep -v grep
	        		if test $? -ne 0
	        		then
		    		  iptables -t nat -N delegate_pre
					else
					  iptables -t nat -F delegate_pre
					fi
			    	iptables -t nat -D PREROUTING -p tcp -j delegate_pre
				    iptables -t nat -I PREROUTING -p tcp -j delegate_pre
		    		sleep 10
					iptables -t nat -vL |grep SS_SPEC_LAN_DG |grep Chain |grep -v grep
        			if test $? -ne 0
		        	then
					    sleep 10
		        		continue
        			else
					    iptables -t nat -F delegate_pre
    			    	iptables -t nat -I delegate_pre -p all -j SS_SPEC_LAN_DG
   	    				iptables -t nat -I delegate_pre -p tcp -m set --match-set chinalist dst -j RETURN
						iptables -t nat -I delegate_pre -p tcp -m set --match-set xjip dst -j RETURN
						##iptables -t nat -A SS_SPEC_WAN_FW -p tcp -j REDIRECT --to-port 1099
    	    			iptables -t nat -I delegate_pre -p tcp -m set --match-set xjlist dst -j REDIRECT --to-port 1080
						iptables -t nat -A delegate_pre -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-port 1080
						iptables -t nat -A delegate_pre -p tcp -m set --match-set foreign dst -j REDIRECT --to-port 1080
	    	    		##iptables -t nat -I delegate_pre -p tcp -m set --match-set adsblock dst -j REDIRECT --to-port 10086
		    	    	iptables -t nat -A delegate_pre -p tcp -j RETURN
						iptables -t nat -I delegate_pre -p tcp -m iprange --src-range 192.168.6.2-192.168.6.10 -j REDIRECT --to-port 1080
    			    	logger -t "ssmon: ss-redir detected, apply scripts. PID" $pid
	    			    break
    				fi
				else
				    logger -t "ssmon: Another delegate_pre have been created, pid" $pid
	    			break
				fi
			fi
		fi
	done
else
	logger -t "ssmon: ss-wall found. Multi startup detected, skip. MPID" $pidrun
	logger -t "ssmon: Nothing to do. PID "$pid
fi
logger -t "ssmon: done, task pid " $pid

exit 0

