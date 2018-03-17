<html>
<head>
</head>
<body>
<?php
#force debugging settings
#error_reporting(E_ALL);
#ini_set('display_errors', 1);

#start session storage
session_start();

#extra failsafe for empty session storage
#user must be logged in to access this page
if(isset($_SESSION['username'])){
	$username_=$_SESSION['username'];
}
else{
	header('Location: forum.php');
	exit();
}

#get the title, or set it to empy if null
if(isset($_POST['title'])){
	$title_=trim(htmlspecialchars($_POST['title']));
}
else{
	$title_='';
}

#get form input data and sanitize it to help prevent sql injection
#has failsafes for empty required form fields in webkit browsers
#todo: show error message upon return -> send by POST method
if(isset($_POST['topic_id'])&&(trim(htmlspecialchars($_POST['topic_id']))!=='')){
	$post_id=trim(htmlspecialchars($_POST['topic_id']));
	if(!isset($_POST['title'])||($title_=='')){
		header('Location: forum.php');
		exit();
	}
	$dest='Location: topic.php?topic_id='.$post_id;
	$procedure="update_topic";
}
else if(isset($_POST['post_id'])&&(trim(htmlspecialchars($_POST['post_id']))!=='')){
	$post_id=trim(htmlspecialchars($_POST['post_id']));
	$dest='Location: topic.php?post_id='.$post_id;
	$procedure="update_post";
}
else{
	header('Location: forum.php');
	exit();
}
if(isset($_POST['message'])){
	$message_=trim(htmlspecialchars($_POST['message']));
}
else{
	header('Location: forum.php');
	exit();
}

#sql connection
$mysqli = new mysqli("localhost","anon","tendies","forum");

#sql query
#submits the post or topic edit
$query1="call ".$procedure."('".$post_id."','".$title_."','".$message_."','".$username_."')";

#check for a successful connection
if($mysqli->connect_errno){
	echo "Failed to connect to MySQL: (".$mysqli->connect_errno.") ".$mysqli->connect_error;
}

#send the sql query
if(!($mysqli->query($query1))){
	echo "Failed to execute procedure: (".$mysqli->connect_errno.") ".$mysqli->connect_error;
}
#close sql connection
mysqli_close($mysqli);

#open topic page at the edited post
header($dest);
exit();
?>
	</body>
</html>
