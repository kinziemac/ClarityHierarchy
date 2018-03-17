<!--Page Scaling for Mobile Browsers-->
<meta name="viewport" content="width=device-width, initial-scale=0.6, maximum-scale=1.0, user-scaleable=yes" />
<html><div class="margins">
<head>
<!--Sitewide Stylesheet-->
<link rel="stylesheet" href="forum.css">

<!--Page Heading-->
<title>Clarity Forum</title>
<a href="forum.php"><div class="heading"><div class="nav_title">Clarity Project Forum</div></div></a>
</head>

<body>
<!--Page Navigation-->
<hr align=left size=1 width=100% noshade/>
<div class="heading"><div class=nav_title>HOME PAGE</div></div>
<hr align=left size=1 width=100% noshade/>

<?php
#for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);
#start session storage
session_start();

#log out (called upon user interaction)
if(isset($_POST['clear_username'])){
	unset($_SESSION['username']);
/*	header('Location: forum.php');
	exit();*/
	$success="You have been logged out successfully!";
}
#success message for account deletion
if(isset($_SESSION['account_deleted'])){
	$success="Your account, likes, topics and posts have all been deleted successfully.";
	unset($_SESSION['account_deleted']);
}
# display success message
if(isset($success)){ ?>
<div class="success"><div class="success-title">Success:</div>
<div class="success-text"><?php echo $success ?></div>
</div>
<?php }

#display user login and signup forms if user is not logged in
if(!isset($_SESSION['username'])){ ?>
<!--User Login Form-->
<div class="field"><form action="login.php" method="post" class="entry"><div class="title"><p class="title">Login</p></div>
<!--Username Field-->
<p><label class="field" for="username"><span class="field">*</span>username:</label><input class="replybox" type="text" name="username" maxlength="20" placeholder="required" required/></p>
<!--Password Field-->
<p><label class="field" for="password"><span class="field">*</span>password:</label><input class="replybox" type="password" name="password" maxlength="1000" placeholder="required" required/></p>
<!--Submission Button-->
<input type="hidden" value=true name="login"/><p><div class="submit"><input type="submit"/></div></p>
</form></div>

<!--User Signup Form-->
<div class="field"><form action="login.php" method="post" class="entry"><div class="title"><p class="title">Sign Up</p></div>
<!--Username Field-->
<p><label class="field" for="username"><span class="field">*</span>username:</label><input class="replybox" type="text" name="username" maxlength="20" placeholder="required" required/></p>
<!--Email Field-->
<p><label class="field" for="email"><span class="field">*</span>email:</label><input class="replybox" type="text" name="email" maxlength="50" placeholder="required" required/></p>
<!--Password Field-->
<p><label class="field" for="password"><span class="field">*</span>password:</label><input class="replybox" type="password" name="password" maxlength="1000" placeholder="required" required/></p>
<!--Hidden Field for flag-->
<input type="hidden" value=true name="signup"/>
<!--Submission Button-->
<p><div class="submit"><input type="submit"/></div></p>
</form></div>
<?php 
#set login flag
$logged_in=false;
}else{
#set login flag and display account management button, welcome message, and user logout button
$logged_in=true;
?>
<div class="navigation">
<!--Account Management Button-->
<form action="account.php"><button class="button_logout" type=submit>Account</button></form>
<!--Welcome Message-->
<div class="nav_title">Welcome, <?php echo $_SESSION['username'] ?>!</div>
<!--User Logout Button-->
<form action="forum.php" method="post"><input type="hidden" name="clear_username" value=true/><button class="button_logout" type=submit>Logout</button></form>
</div>
<?php } ?>

<!--New Topic Submission Form-->
<div class="field"><form action="action.php" method="post" class="entry"><div class="title"><p class="title">Create a Topic</p></div>
<!--Username Field-->
<p><label class="field" for="username">username:</label><input class="replybox" type="text" name="username" maxlength="20" value="<?php if($logged_in){echo $_SESSION['username'];}else{echo "anonymous user";} ?>" disabled/></p>
<!--Title Field-->
<p><label class="field" for="title"><span class="field">*</span>title:</label><input class="replybox" type="text" name="title" maxlength="50" placeholder="required" required/></p>
<!--Message Field-->
<p><label class="field" for="message"><span class="field">*</span>message:</label><textarea rows="5" name="message" maxlength="1000" placeholder="required" required></textarea></p>
<!--Submit Button-->
<p><div class="submit"><input type="submit"/></div></p>
</form></div>

<div class="heading"><div class=nav_title>Topic List:</div></div>

<?php
#sql connection
$mysqli = new mysqli("localhost","anon","tendies","forum");
if ($mysqli->connect_errno){
	echo "Failed to connect to MySQL: (".$msqli->connect_errno.") ".$mysqli->connect_error;
}
#query: get the full list of topics
#returns: list of topics and topic metadata
$query="call list_topics()";
#result array
$posts=array();
#send sql query
if($mysqli->multi_query($query)){
	if($res=$mysqli->store_result()){
		while($row=$res->fetch_row()){
			$posts[]=array(
				'username'=>$row['0'],
				'topic_id'=>$row['1'],
				'topic_date'=>$row['2'],
				'topic_title'=>$row['3']
			);
		}
		$mysqli->next_result();
	}
}

#close sql connection
mysqli_close($mysqli);

#time/date formatting strings
$timezone=-7;
$dateline="d-m-y \\a\\t g:iA";
$dateline1="d-m-y";
$dateline2="g:iA";

#display topic headers
if(!isset($posts[0])){
?>
<p style="font-size:1.5em;">There are no topics to show.</p>
<?php
}
for($i=0;$i<count($posts);$i=$i+1){ ?>
<!--Topic List-->
<div class="flex-container2">
<div class="flex-item1"><a href="topic.php?topic_id=<?php echo $posts[$i]['topic_id']?>&page=0"><?php echo $posts[$i]['topic_title']?></a></div>
<div class="flex-item2">By: <?php echo $posts[$i]['username']?></div>
<div class="flex-item2">TopicID: <?php echo $posts[$i]['topic_id']?></div>
<div class="flex-item2">Date: <?php echo gmdate($dateline1,$posts[$i]['topic_date']+3600*($timezone+date("I")))?></div>
<div class="flex-item2">Time: <?php echo gmdate($dateline2,$posts[$i]['topic_date']+3600*($timezone+date("I")))?></div>
</div>
<?php } ?>
</body>
</div></html>
