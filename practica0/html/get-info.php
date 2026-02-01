<?php
  $id = exec('uname -nrsm');
  $os = exec('. /etc/os-release && echo $NAME');
  $version = exec('. /etc/os-release && echo $VERSION');
  $cpu = exec('cat /proc/cpuinfo | grep "model name" | head -1 | cut -d ":" -f 2');
  echo "<p>$os $version $id</p>";
  echo "<p>$cpu</p>\n";
  include 'db-get-data.php' ;
?>
