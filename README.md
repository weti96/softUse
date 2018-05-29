# softether用户流量查询

**前言**

基友们合租服务器，用softether工具来搭建vpn，由于流量有限，因此每个人希望查询自己用了多少。得知softether server自带流量统计，那么弄起来就轻松很多了。我们需要提取softether server的流量（字节），转换为MB、GB，然后网页可视化显示。

> 环境:nginx+php7.1.14+softether server

___

## 提取流量统计

创建new.sh在```你的路径/vpnserver``` 文件夹下

```shell
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
	echo $virtual_hub
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
```
**注意**

由于为了便于提取，一定要把*UserName FullName GroupName Description* 字段全填数据

## 网页可视化
> 需要开启php的shell_exec
>
> ```shell
> vi /usr/local/php/etc/php.ini
> #从disable_functions中去除shell_exec
> ```

创建index.php(名字随意)

```php
<html>
<head>
    <link rel="stylesheet" type="text/css" href="index.css">
    <link href="time.png" rel="shortcut icon">
</head>
<body>
<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center">
  <tr>
    <td align="center" class="biaoti" height="60">实时流量统计表</td>
  </tr>
  <td align="right" height="25"><?php echo date('Y-m-d H:i:s')?></td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="1" cellpadding="4" bgcolor="#cccccc" class="tabtop13" align="center">
    <tr>
        <th width="20%" class="btbg font-center titfont" rowspan="2">用户名</th>
        <th width="20%" class="btbg font-center titfont" rowspan="2">登录方式</th>
        <th width="20%" class="btbg font-center titfont" rowspan="2">登录次数</th>
        <th width="20%" class="btbg font-center titfont" rowspan="2">最后登录时间</th>
        <th width="20%" class="btbg font-center titfont" rowspan="2">已使用流量</th>
    </tr>
    <?php
    //执行脚步文件重定向文件
    // $use=shell_exec("uname -r");
    // var_dump($use);
    shell_exec("sudo -S bash /root/vpnserver/new.sh > result.txt 2>&1");
   
    $array = [];
    //读取文件，一行一个数组
    $fd = file("result.txt");
    if ($fd === NULL) {
        echo "error";
    }
    //去除转义字符
    $result = str_replace("\\n", "", str_replace("\n", "", $fd));
    //蠢方法解决表格排版
    echo "<tr></tr>";
    //遍历输出数组
    foreach ($result as $data) {
        $value = explode("|", $data);
        //格式化
        // echo "\n";
        echo "<tr>";
        foreach ($value as $item) {
            if($item==="")
            break;
            echo "<td>$item</td>";
            //格式化
            // echo "\n";
        }
        echo "</tr>";
    }
    ?>
</table>
</body>
</html>
```
index.css

```css
@charset "utf-8";
/* CSS Document */
.tabtop13 {
    margin-top: 13px;
}
.tabtop13 td{
    background-color:#ffffff;
    height:25px;
    line-height:150%;
}
.font-center{ text-align:center}
.btbg{background:#e9faff !important;}
.btbg1{background:#f2fbfe !important;}
.btbg2{background:#f3f3f3 !important;}
.biaoti{
    font-family: 微软雅黑;
    font-size: 26px;
    font-weight: bold;
    border-bottom:1px dashed #CCCCCC;
    color: #255e95;
}
.titfont {

    font-family: 微软雅黑;
    font-size: 16px;
    font-weight: bold;
    color: #255e95;
    background-color:#e9faff;
}
.tabtxt2 {
    font-family: 微软雅黑;
    font-size: 14px;
    font-weight: bold;
    text-align: right;
    padding-right: 10px;
    color:#327cd1;
}
.tabtxt3 {
    font-family: 微软雅黑;
    font-size: 14px;
    padding-left: 15px;
    color: #000;
    margin-top: 10px;
    margin-bottom: 10px;
    line-height: 20px;
}
```

**注意**
> php执行shell脚本的路径在php文件当前目录，即生成的**result.txt**文件在index.php目录下
>
> ```shell
> #当查看result.txt出现no permission时，修改 *.txt文件权限
> chmod 777 *.txt
> ```


## 效果

![title](http://t1.aixinxi.net/o_1cehd8kec1rit5jp1js916hug8ua.png-j.jpg)

## 常见错误
```shell
#如果shell_exec还是显示NULL，但是网页无显示或显示错误，请根据错误去解决（确认路径文件的前提）
#我遇到过几种
1. permission denied
>chmod 755 *.txt
>chmod -R 755 new.sh

2. unable to host XXX
>sudo vi /etc/hosts #在127.0.0.1后面yyy替换为xxx，确保/etc/hostname下的一致

3. sudo passwd:XXX
>sudo visudo #添加"www ALL=(ALL) NOPASSWD:ALL",设置www所有者用sudo执行/修改文件时不需要输入密码 

4. 其他错误可以查看123.txt。info.txt、info_new.txt等文件显示
```
## 结论

代码惨不忍睹

