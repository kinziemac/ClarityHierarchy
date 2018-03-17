<html>
<head></head>
<body>
<?php
#force debugging settings
#error_reporting(E_ALL);
#ini_set('display_errors', 1);

#start session storage
session_start();

#failsafe for empty session storage
#user must be logged in to use this feature
if(isset($_SESSION['username'])){
	$username=$_SESSION['username'];
}
else{
	echo "Please Login";
	exit();
}

#failsafe for nonexistant form data
if(isset($_POST['post_id'])){
	$post_id=$_POST['post_id'];
	$procedure="rate_post";
}else if(isset($_POST['topic_id'])){
	$post_id=$_POST['topic_id'];
	$procedure="rate_topic";
}else{
	echo "no_id";
	exit();
}

#sql query:
#rate the topic or post
#returns: total topic or post rating
$query1="call ".$procedure."('".$post_id."','".$username."')";

#sql connection
$mysqli=new mysqli("localhost","anon","tendies","forum");

#check for successful connection
if($mysqli->connect_errno){
	echo "con_err";
	exit();
}
#send sql query
if(!($res=$mysqli->query($query1))){
	echo "que_err";
	exit();
}
#convert result rows into array items
$row=$res->fetch_assoc();
$rating=$row['rating'];

#close sql connection
mysqli_close($mysqli);

#output query result
echo $rating;
?>
</body>
</html>
