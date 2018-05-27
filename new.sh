#! /bin/bash
#你创建的hub
virtual_hub="DEFAULT"
separator="---------------------------------------------------------------"

VAR="UserName FullName GroupName Description AuthMethod NumLogins LastLogin ExpirationDate TransferBytes TransferPackets"
FILE_SEPARATOR="\|"
# 分割线
separator() {
	echo "$separator"
}
# 单位转换
calc_flow() {
	a=`echo $1 | sed -r 's/\,//g' -`
	use_flow=$((10#${a}))
	if [ $use_flow -ge 1073741824 ];then
		use_high=`expr $use_flow / 1073741824`
		use_low=`expr $use_flow % 1024`
		use_end="${use_high}.${use_low}GB"
	else
		use_high=`expr $use_flow / 1048576`
		use_low=`expr $use_flow % 1024`
		use_end="${use_high}.${use_low}MB"
	fi
	echo $use_end
}
get_user(){
	sleep 0.1
	# echo "获取用户列表"
	# separator
	(
	echo "1"
	echo "localhost"
	echo "DEFAULT"
	echo "userlist"
	echo "exit"
	) | /root/vpnserver/vpncmd > info.txt 2>&1
	#不能源文件作重定向文件
	sed 's/[\|]/ /g;s/\+//g;s/Description/des ption/g' info.txt |sed '1,27d;$d'|awk '{for(i=3;i<=NF;i++) printf "%s",$i;print ""}' > 123.txt 2>&1
	sed 's/^$/\|/g' 123.txt |tr -t "\n" "\t" |tr -t "\|" "\n" |sed 's/^\t//g'|sed 's/\t/\|/g' > info_new.txt 2>&1
	#解决read无法读最后一行
	echo "\n" >> info_new.txt
	#rm info.txt
	# echo -e "  用户名  \t-  认证方式  \t-  登录次数  \t-  使用流量"
	# while IFS=$FILE_SEPARATOR read $VAR; do
	# 	use_flow=`calc_flow "$TransferBytes"`
	# 	echo -e "  $UserName  \t-  $AuthMethod  \t-  $NumLogins  \t-  $use_flow"
	# done < info_new.txt
	while IFS=$FILE_SEPARATOR read $VAR; do
		use_flow=`calc_flow "$TransferBytes"`
		echo -e "$UserName|$AuthMethod|$NumLogins|$LastLogin|$use_flow\n"
	done < info_new.txt 2>&1
}

get_user
exit 0