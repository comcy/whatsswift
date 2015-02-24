<?php
     session_start();

     $hostname = $_SERVER['HTTP_HOST'];
     $path = dirname($_SERVER['PHP_SELF']);

     if (!isset($_SESSION['angemeldet']) || !$_SESSION['angemeldet']) {
      header('Location: http://'.$hostname.($path == '/' ? '' : $path).'/login.php');
      exit;
      }
?>

<!DOCTYPE html>
<html class="no-js">
<head>
  <meta charset="utf-8" />
  <title>WhatsSWIFT WebSocket Chat</title>
  <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
  <style type="text/css" media="screen">
    li span {
      color: #66ccff;
    }
    .success {
      color: green;
    }
    .error {
      color: red;
    }

	input, textarea {
		border:1px solid #CCC;
		margin:0px;
		padding:0px;
	}

	#body {
		max-width: 800px;
		margin:auto;
		border:thin solid #CCCCFF; 
		font-size:150%";
	}

	#chat {
		width:40%;
		height:600px;
		overflow: scroll;
		background-image:url(swift.jpg);		
		//color:#00FF00;	
	}

	#input {
		width: 40%;
		line-height: 30px;
		font-size: 100%;
	}
	
	#username {
		width: 40%;
		line-height: 30px;
		font-size: 100%;
	}
	
	input[type="submit"] {
	        background-color: buttonface;
	        color: buttontext;
	        font: -moz-button;
	        height: 4em;
	        width: 40%;
	        background-color: lightgrey;
	}

	input[type="button"] {
                background-color: buttonface;
                color: buttontext;
                font: -moz-button;
                height: 4em;
                width: 40%;
                background-color: lightgrey;
        }

  </style>
</head>
<body>

  <script>
var conn = new WebSocket('ws://141.18.49.242:9090');
      var mess = document.getElementById('message');
      var username = document.getElementById('username');
      var chat = document.getElementById('chat')//
      var connected = false;
      var echo_counter = 0;
      var m = function(string, cname) {
        mess.className = cname;
        mess.innerHTML = string;
      }
      // let us know we are live
      conn.onopen = function(e) {
        m("Server started! - Username: <?php Print($_SESSION['ws_username']); ?>", 'success');
        connected = true;

        //send connect message
        var data = {username: "<?php Print($_SESSION['ws_username']); ?>",message: "connected",type: "0"};
        conn.send(JSON.stringify(data));
      };
      //echo system
      setInterval(function(){
        if (connected == true) {
           var data = {username: "<?php Print($_SESSION['ws_username']); ?>", message: "echo",type: "2"};
           conn.send(JSON.stringify(data));
           echo_counter++;
          if (echo_counter >= 3) {
var data = {username: "<?php Print($_SESSION['ws_username']); ?>",message: "disconnected",type: "1"};
                conn.send(JSON.stringify(data));
window.location.replace("logout.php");
          }
        }
      },5000);
      // if offline
      conn.onclose = function(e) {
        m("Server stopped!", 'error');
        connected = false;
      };
      // when a new message is created
      conn.onmessage = function(e) {
        var data = JSON.parse(e.data);
        newChat(data);
      };
      // add message to display
      function newChat(obj) {
        var template = "<b> " + obj.username + "</b>: " + "<i>" +  obj.message +
        "</i><br/>";
        if (obj.message != "echo") {
           chat.innerHTML += template;
        }
        else {
           echo_counter=0;
        }
      }
  



  document.addEventListener('DOMContentLoaded', function() {
      var conn = new WebSocket('ws://141.18.49.242:9090');
      var mess = document.getElementById('message');
      var username = document.getElementById('username');
      var chat = document.getElementById('chat')//
      var connected = false;
      var echo_counter = 0;
      var m = function(string, cname) {
        mess.className = cname;
        mess.innerHTML = string;
      }
      // let us know we are live
      conn.onopen = function(e) {
        m("Server started! - Username: <?php Print($_SESSION['ws_username']); ?>", 'success');
        connected = true;

        //send connect message
        var data = {username: "<?php Print($_SESSION['ws_username']); ?>",message: "connected",type: "0"};
        conn.send(JSON.stringify(data));
      };
      //echo system
      setInterval(function(){
        if (connected == true) {
           var data = {username: "<?php Print($_SESSION['ws_username']); ?>", message: "echo",type: "2"};
           conn.send(JSON.stringify(data));
           echo_counter++;
          if (echo_counter >= 3) {
var data = {username: "<?php Print($_SESSION['ws_username']); ?>",message: "disconnected",type: "1"};
                conn.send(JSON.stringify(data));
window.location.replace("logout.php");
	  }
        }
      },5000);
      // if offline
      conn.onclose = function(e) {
        m("Server stopped!", 'error');
        connected = false;
      };
      // when a new message is created
      conn.onmessage = function(e) {
        var data = JSON.parse(e.data);
        newChat(data);
      };
      // add message to display
      function newChat(obj) {
        var template = "<b> " + obj.username + "</b>: " + "<i>" +  obj.message +
        "</i><br/>";
        if (obj.message != "echo") {
           chat.innerHTML += template;
        }
        else {
           echo_counter=0;
        }
      }

//document.addEventListener('DOMContentLoaded', function() {
      // when new message is entered
      document.forms[0].addEventListener('submit', function(event) {
        event.preventDefault();
        if (this.children[0].value == '') {
          alert('All Fields must be filled');
          return;
        } else if (!connected) {
          alert('connection is closed');
          return false;
        }
        // object prepare
        var data = {username: "<?php Print($_SESSION['ws_username']); ?>", message: this.children[0].value,type: "3"};
        // write to the dom
        //newChat(data);
        // send the data
        conn.send(JSON.stringify(data));
        // empty the field
        this.children[0].value = '';
        // keep the field focused
        this.children[0].focus();
        return false;
      });

    });

      function logout(){
                
                var data = {username: "<?php Print($_SESSION['ws_username']); ?>",message: "disconnected",type: "1"};
                conn.send(JSON.stringify(data));
window.location.replace("logout.php");

        }
	// intervall scrolling in chat window
	window.setInterval(function() {
	  var elem = document.getElementById('chat');
	    elem.scrollTop = elem.scrollHeight;
	    }, 500);

  </script>
	<h1>	
		<img src="swift-logo.png" alt="SWIFT" style="width: 50px;
		height=50px; align:middle">			
		WhatsSWIFT WebSocket Chat </h1>
	<p id="message"></p>	
	
	<br/>
	<br/>
	<!-- <textarea id='chat' name='chat' readonly='readonly'></textarea><br/> -->
	
	<div id="chat" name="chat"></div>
	<form>
		<input type="text" id="input" name="message" value="" placeholder="Enter your Message"><br>
		<br/>
		<input type="submit" name="Submit" value="send">
		<br/>
                <input type="button" onclick="logout();" value="logout">
	</form>

</body>

</html>
