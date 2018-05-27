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
    // $use=shell_exec("whoami");
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
