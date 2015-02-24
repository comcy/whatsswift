<html>

<head>
<script>
function blub() {
     //send logout
     var conn = new WebSocket('ws://141.18.49.242:9090');
     var data = {username: "hhhhhh",message: "disconnect",type: "1"}; 
     conn.send(JSON.stringify(data));
}
</script>
</head>

<body onload="blub();"">
</body>
<?php
    session_start();
    session_destroy();

     $hostname = $_SERVER['HTTP_HOST'];
     $path = dirname($_SERVER['PHP_SELF']);
     header('Location: http://'.$hostname.($path == '/' ? '' : $path).'/login.php');
?>

</html>
