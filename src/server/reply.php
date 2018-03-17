<html>
	<head>
	</head>
	<body>
<?php

#start session storage
session_start();

#set username string depending on login status
if(isset($_SESSION['username'])&&$_SESSION['username']!==''){
	$username_=$_SESSION['username'];
}
else{
	$username_="anonymous user";
}

#get form input data and sanitize it to help prevent sql injection
#has failsafes for empty required form fields in webkit browsers
#todo: show error message upon return -> send by POST method
if(isset($_POST['topic_id'])&&isset($_POST['message'])){
	$topic_id_=htmlspecialchars($_POST['topic_id']);
	$message_=trim(htmlspecialchars($_POST['message']));
	if(isset($_POST['title'])){
		$title_=trim(htmlspecialchars($_POST['title']));
	}
	else{
		$title_='';
	}
	if($topic_id_==''||$message_==''){
		header('Location: topic.php?topic_id='.$topic_id_);
		exit();
	}
}else{
	header('Location: topic.php?topic_id='.$topic_id_);
	exit();
}

#sql query:
#create reply to topic
#returns unique identifier post_id
$query2="call make_post('".$username_."','".$topic_id_."','".$title_."','".$message_."')";

#sql connection
$mysqli = new mysqli("localhost","anon","tendies","forum");
#check for successful connection
if ($mysqli->connect_errno){
	echo "Failed to connect to MySQL: (".$msqli->connect_errno.") ".$mysqli->connect_error;
}

#send the sql query
if(!($res = $mysqli->query($query2))){
	echo "Post creation failed: (".$mysqli->errno.") ".$mysqli->error;
}
#convert result rows to an array, and then fetch the variables
$row = $res->fetch_assoc();
$post_id=$row['post_id'];

#close sql connection
mysqli_close($mysqli);

#open topic page
header('Location: topic.php?post_id='.$post_id);
exit();
?>
</body>
</html>
