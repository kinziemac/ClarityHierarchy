<html>
<head>
</head>
<body>
<?php
#start session storage
session_start();

#for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

if(isset($_POST['title'])&&isset($_POST['message'])){
	#get form input data and sanitize it to help prevent sql injection
	$title_=trim(htmlspecialchars($_POST['title']));
	$message_=trim(htmlspecialchars($_POST['message']));
	#extra failsafe for empty required form fields in webkit browsers
	#this condition is prevented by the previous page
	if($message_==''||$title_==''){
		header('Location: forum.php');
		exit();
	}
}else{
	header('Location: forum.php');
	exit();
}

#set username string depending on login status
if(isset($_SESSION['username'])){
	$username_=$_SESSION['username'];
}
else{
	$username_="anonymous user";
}

#sql queries
$query2="call make_topic('".$username_."','".$title_."','".$message_."')";

#sql connection
$mysqli = new mysqli("localhost","anon","tendies","forum");

#check for successful connection
if ($mysqli->connect_errno){
	echo "Failed to connect to MySQL: (".$msqli->connect_errno.") ".$mysqli->connect_error;
}

#create topic
#returns unique identifier topic_id
if(!($res = $mysqli->query($query2))){
	echo "Topic creation failed: (".$mysqli->errno.") ".$mysqli->error;
}
#convert result rows into array items
$row = $res->fetch_assoc();
$topic_id=$row['topic_id'];

#close sql connection
mysqli_close($mysqli);

#open topic page
header('Location: topic.php?topic_id='.$topic_id);
exit();
?>
</body>
</html>
