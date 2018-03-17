<!--Page Scaling for Mobile Browsers-->
<meta name="viewport" content="width=device-width, initial-scale=0.6, maximum-scale=1.0, user-scaleable=yes" />
<html><div class="margins">
<?php session_start();
#for debugging
#error_reporting(E_ALL);
#ini_set('display_errors', 1);

#extra failsafe for empty session storage
#user must be logged in to access this page
if(!isset($_SESSION['username'])){
	header('Location: forum.php');
	exit();
}

#get form input data and sanitize it to help prevent sql injection
if(isset($_POST['title'])){
	$title_=trim(htmlspecialchars($_POST['title']));
}
else{
	$title_='';
}
if(isset($_POST['message'])){
	$message_=trim(htmlspecialchars($_POST['message']));
}
else{
	$message_='';
}
if(isset($_POST['topic_id'])&&(trim(htmlspecialchars($_POST['topic_id']))!=='')){
	$topic_id=trim(htmlspecialchars($_POST['topic_id']));
	$topic_edit=true;
	$return="topic_id=".$topic_id;
}
else if(isset($_POST['post_id'])&&(trim(htmlspecialchars($_POST['post_id']))!=='')){
	$post_id=trim(htmlspecialchars($_POST['post_id']));
	$topic_edit=false;
	$return="post_id=".$post_id;
}
#failsafe for an undefined condition
else{
	header('Location: forum.php');
	exit();
}
?>

<head>
<!--Sitewide Stylesheet-->
<link rel="stylesheet" href="forum.css">
<title>Clarity Forum: Edit</title>

<!--Page Heading-->
<a href="forum.php"><div class="heading"><div class="nav_title">Clarity Project Forum [Return]</div></div></a>
</head>

<body>
<!--Page Navigation-->
<hr size=1 width=100% align=left noshade>
<a href="topic.php?<?php echo $return ?>"><div class="heading"><div class="nav_title">EDITING TOPIC OR POST [Return]</div></div></a>
<hr size=1 width=100% align=left noshade>

<!--Post/Topic Edit Form-->
<div class="field"><form action="subm_edit.php" method="post" class="entry"><div class="title"><p class="title">Edit this Post or Topic</p></div>
<!--Username Field-->
<p><label class="field"	for="username">username:</label><input class="replybox" type="text" name="username" maxlength="20" value="<?php echo $_SESSION['username'] ?>" disabled/></p>
<!--Title Field-->
<p><label class="field" for="title"><?php if($topic_edit){ ?><span class="field">*</span><?php } ?>title:</label><input class="replybox" type="text" name="title" maxlength="50" placeholder="required" value="<?php echo $title_ ?>" <?php if($topic_edit){ ?> required <?php } ?>/></p>
<!--Message Field-->
<p><label class="field" for="message"><span class="field">*</span>message:</label><textarea rows="5" name="message" maxlength="1000" placeholder="required" required><?php echo $message_ ?></textarea></p>
<?php if($topic_edit){ ?> <input type="hidden" name="topic_id" value="<?php echo $topic_id ?>"/><?php }else{ ?><input type="hidden" name="post_id" value="<?php echo $post_id ?>"/><?php } ?>
<!--Submission Button-->
<p><div class="submit"><input type="submit"/></div></p>
</form></div>
</body>
</div></html>
