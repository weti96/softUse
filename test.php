<?php
echo "123";
var_dump(get_current_user());
$cmd = 'php -v';
exec($cmd, $arr);
echo '<pre>';
var_dump($arr);
?>