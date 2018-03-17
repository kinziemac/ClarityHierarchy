<!--Page Scaling for Mobile Browsers-->
<meta name="viewport" content="width=device-width, initial-scale=0.6, maximum-scale=1.0, user-scaleable=yes" />
<html><div class="margins">
<head>
<!--Page Heading-->
<title>Clarity Forum: Topic</title>
<a href="forum.php"><div class="heading"><div class="nav_title">Clarity Project Forum [Return]</div></div></a>
<link rel="stylesheet" href="forum.css">
<!--JQuery included for AJAX-->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"/></script>
<!--JavaScript for Post and Topic 'Like' Buttons-->
<script>
//fuction to 'like' a post
//Upon user interaction with the corresponding 'Like' button,
//Sends a request to a page that updates the post's 'Like' rating and returns the total rating.
//Updates the number of 'Likes' displayed for the post.
function rate_post(post_id){
	document.getElementById("post_rating"+post_id).innerHTML="...";
	if(window.XMLHttpRequest){
		xmlhttp = new XMLHttpRequest();
	}
	xmlhttp.open("POST","rate.php",true);
	xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	xmlhttp.onload=function(){
		if (this.readyState==4&&this.status==200) {
			document.getElementById("post_rating"+post_id).innerHTML=this.responseText;
		}
	}
	xmlhttp.send("post_id="+post_id);
}
//fuction to 'like' a post
//Upon user interaction with the corresponding 'Like' button,
//Sends a request to a page that updates the topic's 'Like' rating and returns the total rating.
//Updates the number of 'Likes' displayed for the topic.
function rate_topic(topic_id){
	document.getElementById("topic_rating").innerHTML="...";
	if(window.XMLHttpRequest){
		xmlhttp = new XMLHttpRequest();
	}
	xmlhttp.open("POST","rate.php",true);
	xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	xmlhttp.onload=function(){
		if (this.readyState==4&&this.status==200) {
			document.getElementById("topic_rating").innerHTML=this.responseText;
		}
	}
	xmlhttp.send("topic_id="+topic_id);
}
</script>
</head>
<body>
<?php
#for debugging
#error_reporting(E_ALL);
#ini_set('display_errors', 1);

#start session storage
session_start();

#set 'user logged in' flag
if(isset($_SESSION['username'])){
	$logged_in=true;
}else{
	$logged_in=false;
}
#set the number of posts shown on each page
if(isset($_SESSION['posts_per_page'])){
	$posts_per_page=$_SESSION['posts_per_page'];
}else{
	$posts_per_page=10;
}
#get the current page number, or set to zero if not set
if(isset($_GET['page'])){
	$page_=htmlspecialchars($_GET['page']);
}else{
	$page_=0;
}
#calculate the post offest for the sql query
$post_offset=$posts_per_page * $page_;
#sql connection
$mysqli = new mysqli("localhost","anon","tendies","forum");

#load the given topic
if(isset($_GET['topic_id'])){
	$topic_=htmlspecialchars($_GET['topic_id']);
}
#handle comment permalinks
else if(isset($_GET['post_id'])){
	#get the post_id linked to
	$post_id_=htmlspecialchars($_GET['post_id']);
	#sql query: get the topic_id of the topic to which the post specified by post_id belongs
	#returns topic_id of the parent topic
	$query4="call get_topic_from_post('".$post_id_."')";
	#check for a successful connection
	if ($mysqli->connect_errno){
		echo "Failed to connect to MySQL: (".$msqli->connect_errno.") ".$mysqli->connect_error;
	}
	#send sql query
	if(!($res=$mysqli->query($query4,MYSQLI_STORE_RESULT))){
		echo "Getting topic from post failed: (".$mysqli->errno.") ".$mysqli->error;
	}
	#store results in an array and extract the required key
	$row = $res->fetch_assoc();
	$topic_=$row['topic_id'];

	#skip over null results
	$mysqli->next_result();
	$mysqli->next_result();

	#sql query: get the post's position within the topic
	#returns: post's position (1-based index) within the topic
	$query5="call get_post_rownumbers('".$post_id_."','".$topic_."')";
	if((!$res=$mysqli->query($query5,MYSQLI_STORE_RESULT))){
		echo "Getting post rownumber failed: (".$mysqli->errno.") ".$mysqli->error;
	}
	#store results in an array and extract the required key, and convert it to a 0-based index
	$row2 = $res->fetch_assoc();
	$rank_=$row2['rank']-1;

	#close the sql connection
	mysqli_close($mysqli);

	#failsafe for nonexistant topic
	if(!($topic_>0)){
		header('Location: forum.php');
		exit();
	}

	#calculate the page number, and post's position within the page
	$page=(int)(floor($rank_/$posts_per_page));
	$post=$rank_%$posts_per_page+1;

	#open the page at the specified post
	header('Location: topic.php?topic_id='.$topic_.'&page='.$page.'#post'.$post);
	exit();
}else{
	#failsafe for nonexistant post
	header('Location: forum.php');
	exit();
}

#sql query: get topic
#returns the complete topic data
$query1="call get_topic('".$topic_."')";
#sql query: get some replies by topic
#returns the complete post data for reply posts within the specified range in the specified topic
$query2="call get_some_replies_by_topic('".$topic_."','".$post_offset."','".$posts_per_page."')";
#sql query: get number of replies
#returns the total number of replies to the specified topic
$query3="call get_num_replies('".$topic_."')";

#check for successful sql connection
if ($mysqli->connect_errno){
	echo "Failed to connect to MySQL: (".$msqli->connect_errno.") ".$mysqli->connect_error;
}
#send queries
$posts=array();
$num_replies=0;
if($mysqli->multi_query($query3.";".$query1.";".$query2)){
	#query3
	if($res=$mysqli->store_result()){
		#fetch results into an array
		while($row=$res->fetch_row()){
			$num_replies=$row['num_replies'];
		}
		#skip over null results
		$mysqli->next_result();
		$mysqli->next_result();
	}
	#query1
	if($res=$mysqli->store_result()){
		while($row=$res->fetch_row()){
			#fetch results into an array
			$posts[]=array(
				'username'=>$row['0'],
				'post_id'=>$row['1'],
				'post_date'=>$row['2'],
				'post_title'=>$row['3'],
				'post_text'=>$row['4'],
				'rating'=>$row['5'],
				'last_edit'=>$row['6'],
				'last_edited_by'=>$row['7']
			);
		}
		#skip over null results
		$mysqli->next_result();
		$mysqli->next_result();
	}
	#query2
	if($res=$mysqli->store_result()){
		while($row=$res->fetch_row()){
			#fetch results into an array
			$posts[]=array(
				'username'=>$row[0],
				'post_id'=>$row[1],
				'post_date'=>$row[2],
				'post_title'=>$row[3],
				'post_text'=>$row[4],
				'rating'=>$row[5],
				'last_edit'=>$row[6],
				'last_edited_by'=>$row[7]
			);
		}
		#free result
		$res->free();
	}
}

#close sql connection
mysqli_close($mysqli);

#failsafe for nonexistant topic
if($posts[0]['post_id']==''){
	header('Location: forum.php');
	exit();
}
#failsafe for nonexistant page
if(!isset($posts[1]['post_id'])&&($num_replies>0)){
	header('Location: topic.php?topic_id='.$topic_);
	exit();
}
#time and date formatting strings
$timezone=-7;
$dateline="d-m-y \\a\\t g:iA";
$dateline1="d-m-y";
$dateline2="g:iA";
#calculate next, previous and last pages
$nextpage = $page_+1;
$prevpage = $page_+-1;
$lastpage = floor($num_replies/$posts_per_page)+1;
#set flag to disable next or previous buttons if there is no next or previous page
if($prevpage<0) $prev_disabled=true;
else $prev_disabled=false;
if($nextpage>($num_replies/$posts_per_page)) $next_disabled=true;
else $next_disabled=false;

?>
<!--Page Navigation-->
<hr size=1 width=100% align=left noshade>
<div class="navigation">
<!--Previous Page Button-->
<form action="topic.php" method="get"><input type="hidden" name="topic_id" value="<?php echo $topic_ ?>"/><input type="hidden" name="page" value="<?php echo $prevpage ?>"/><button class="button_left" type="submit" <?php if($prev_disabled) echo "disabled" ?>>Prev</button></form>
<!--Page Title-->
<div class=nav_title>VIEWING TOPIC PAGE <?php echo $nextpage." of ".$lastpage?></div>
<!--Previous Page Button-->
<form action="topic.php" method="get"><input type="hidden" name="topic_id" value="<?php echo $topic_ ?>"/><input type="hidden" name="page" value="<?php echo $nextpage ?>"/><button class="button_right" type=submit <?php if($next_disabled) echo "disabled" ?>>Next</button></form>
</div>
<hr size=1 width=100% align=left noshade>

<!--Topic Post-->
<div class="flex-container">
<!--Topic Post Title-->
<div class="flex-title"><?php echo $posts[0]['post_title']?></div>

<!--Topic Post Information Panel-->
<div class="flex-info">
By: <?php echo $posts[0]['username']?><br>
TopicID: <?php echo $posts[0]['post_id']?><br>
Date: <?php echo gmdate($dateline1,$posts[0]['post_date']+3600*($timezone+date("I")))?><br>
Time: <?php echo gmdate($dateline2,$posts[0]['post_date']+3600*($timezone+date("I")))?><br>
<?php if($posts[0]['last_edit']!==NULL){ #If the post was edited, show the last date it was edited and by whom
	echo "Edited: ".gmdate($dateline1,$posts[0]['last_edit']+3600*($timezone+date("I")))."<br>";
	echo "At: ".gmdate($dateline2,$posts[0]['last_edit']+3600*($timezone+date("I")))."<br>";
	echo "By: ".$posts[0]['last_edited_by'];
} ?><br>
Likes: <div style="display:inline;" id="topic_rating"><?php echo $posts[0]['rating'] ?></div><br>

<!--Edit and 'Like' Buttons-->
<div class=edit_button>
<?php if($logged_in&&($_SESSION['username']==$posts[0]['username'])){#if this post belongs to the currently logged in user, display an edit button ?>
<!--Edit Button-->
<form id="edit" action="edit.php" method="post">
<!--Hidden Fields for Variables-->
<input type="hidden" name="topic_id" value="<?php echo $topic_ ?>"/>
<input type="hidden" name="title" value="<?php echo $posts[0]['post_title'] ?>"/>
<input type="hidden" name="message" value="<?php echo $posts[0]['post_text'] ?>"/>
<button class="button_edit" type="submit"><div class="button_text">Edit</div></button></form>
<?php } ?>
<!--'Like' Button-->
<button id="rate_topic" class="button_rate" onclick="rate_topic(<?php echo $topic_ ?>);"><div class="button_text">Like</div></button>
</div></div>

<!--Post Text Body-->
<div class="flex-text"><?php echo $posts[0]['post_text'] ?></div>
</div>

<!--Button to Show or Hide the Reply Form (default: hide)-->
<label for="toggle"><div class="flexhide">Show/Hide Reply Form</div></label>
<input class="hideme" type="checkbox" id="toggle" checked/>

<!--Reply Submission Form-->
<div class="hideme"><div class="field"><form action="reply.php" method="post" class="entry"><div class="title"><p class="title">Reply to this Topic</p></div>
<!--Username Field-->
<p><label class="field" for="username">username:</label><input class="replybox" type="text" name="username" maxlength="20" value="<?php if($logged_in){echo $_SESSION['username'];}else{echo "anonymous user";} ?>" disabled/></p>
<!--Title Field-->
<p><label class="field" for="title">title:</label><input class="replybox" type="text" name="title" maxlength="50"/></p>
<!--Message Field-->
<p><label class="field" for="message"><span class="field">*</span>message:</label><textarea rows="5" name="message" maxlength="1000" placeholder="required" required></textarea></p>
<!--Hidden Field for a Variable-->
<input type="hidden" name="topic_id" value="<?php echo $topic_ ?>"/>
<!--Submit Button-->
<p><div class="submit"><input type="submit"/></div></p>
</form></div></div>

<!--Topic Reply Posts-->
<?php for($i=1;$i<count($posts);$i=$i+1){ ?>
<!--Topic Reply Post-->
<div id="post<?php echo $i ?>" class="flex-container">
<!--Post Title-->
<div class="flex-title"><?php echo $posts[$i]['post_title']?></div>

<!--Post Information Sidepanel-->
<div class="flex-info">
By: <?php echo $posts[$i]['username']?><br>
<a href=topic.php?post_id=<?php echo $posts[$i]['post_id']?>>PostID: <?php echo $posts[$i]['post_id']?></a><br>
Date: <?php echo gmdate($dateline1,$posts[$i]['post_date']+3600*($timezone+date("I")))?><br>
Time: <?php echo gmdate($dateline2,$posts[$i]['post_date']+3600*($timezone+date("I")))?><br>
<?php if($posts[$i]['last_edit']!==NULL){ #If the post was edited, show the last date it was edited and by whom
	echo "Edited: ".gmdate($dateline1,$posts[$i]['last_edit']+3600*($timezone+date("I")))."<br>";
	echo "At: ".gmdate($dateline2,$posts[$i]['last_edit']+3600*($timezone+date("I")))."<br>";
	echo "By: ".$posts[$i]['last_edited_by'];
}?>
Likes: <div style="display:inline;" id="post_rating<?php echo $posts[$i]['post_id'] ?>"><?php echo $posts[$i]['rating'] ?></div>

<!--Edit and 'Like' Buttons-->
<div class="edit_button">
<?php if($logged_in&&($_SESSION['username']==$posts[$i]['username'])){#if this post belongs to the currently logged in user, display an edit button ?>
<!--Edit Button-->
<form id="edit" action="edit.php" method="post">
<input type="hidden" name="post_id" value="<?php echo $posts[$i]['post_id'] ?>"/>
<input type="hidden" name="title" value="<?php echo $posts[$i]['post_title'] ?>"/>
<input type="hidden" name="message" value="<?php echo $posts[$i]['post_text'] ?>"/>
<button class="button_edit" type="submit"><div class="button_text">Edit</div></button>
</form>
<?php } ?>
<!--'Like' Button-->
<button id="rate_post" class="button_rate" onclick="rate_post(<?php echo $posts[$i]['post_id'] ?>);"><div class="button_text">Like</div></button>
</div></div>

<!--Post Text Body-->
<div class="flex-text"><?php echo $posts[$i]['post_text'] ?></div>
</div>
<?php } ?>

<!--Previous and Next Page Buttons-->
<div class="navigation">
<!--Previous Page Button-->
<form action="topic.php" method="get"> 
<input type="hidden" name="topic_id" value="<?php echo $topic_ ?>"/>
<input type="hidden" name="page" value="<?php echo $prevpage ?>"/>
<button class="button_left" type="submit" <?php if($prev_disabled) echo "disabled" ?>>Prev</button>
</form>
<!--Next Page Button-->
<form action="topic.php" method="get"> 
<input type="hidden" name="topic_id" value="<?php echo $topic_ ?>"/>
<input type="hidden" name="page" value="<?php echo $nextpage ?>"/>
<button class="button_right" type=submit <?php if($next_disabled) echo "disabled" ?>>Next</button>
</form>
</div>

</body>
</div></html>
