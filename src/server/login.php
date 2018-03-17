<!--Page Scaling for Mobile Browsers-->
<meta name="viewport" content="width=device-width, initial-scale=0.6, maximum-scale=1.0, user-scaleable=yes" />
<html><div class="margins">

<?php #set the page to open after successful login or signup
if(isset($_POST['referral_page'])&&$_POST['referral_page']!==''){
	$return=htmlspecialchars($_POST['referral_page']);
	$referral=true;
}else{
	$return="forum.php";
} ?>

<head>
<!--Sitewide Stylesheet-->
<link rel="stylesheet" href="forum.css">
<!--Page Heading-->
<title>Clarity Forum: Login Page</title>
<?php if($referral){ #don't display a link to the main page if this is a referral ?>
<div class="heading"><div class="nav_title">Clarity Project Forum</div></div>
<?php }else{ ?>
<a href="<?php echo $return ?>"><div class="heading"><div class="nav_title">Clarity Project Forum [Return]</div></div></a>
<?php } ?>
</head>

<body>
<!--Page Navigation-->
<hr size=1 width=100% align=left noshade>
<div class="heading"><div class="nav_title">LOGIN PAGE</div></div>
<hr size=1 width=100% align=left noshade>

<?php
#start session storage
session_start();

#log the user in
if(isset($_POST['login'])){
	#check if all the required fields were filled in
	if(isset($_POST['username'])&&isset($_POST['password'])){
		#sanitize input and check if the strings are empty
		$username=trim(htmlspecialchars($_POST['username']));
		$password=htmlspecialchars($_POST['password']);
		if($username!==''&&$password!==''){
			#sql query: get user secret
			#returns the encrypted hash of the user's password for the given username
			$query1="call get_user_secret('".$username."')";
			#sql connection
			$mysqli = new mysqli("localhost","anon","tendies","forum");
			#check for successful connection
			if ($mysqli->connect_errno){
				echo "Failed to connect to MySQL: (".
				$msqli->connect_errno.") ".$mysqli->connect_error;
			}
			#send sql query
			if(!($res=$mysqli->query($query1,MYSQLI_STORE_RESULT))){
				echo "Login failed: (".$mysqli->errno.") ".$mysqli->error;
			}
			#fetch results
			$row=$res->fetch_assoc();
			#skip over empty results
			$mysqli->next_result();
			$mysqli->next_result();
			if(isset($row['secret'])){
				$secret=$row['secret'];
				$hash = crypt($password, $secret);
				#check if the password matches
				if (hash_equals($secret,crypt($password,$secret))) {
					#calculate a new salt
					$newsalt = sprintf("$2a$%02d$", 10).strtr(base64_encode(random_bytes(16)),'+','.');
					#calculate the resalted password hash
					$newhash = crypt($password, $newsalt);
					#sql query: set a resalted password hash for the given user
					$query3="call set_user_secret('".$username."','".$newhash."')";
					#send sql query
					if(!($res=$mysqli->query($query3,MYSQLI_STORE_RESULT))){
						echo "Rehash failed: (".$mysqli->errno.") ".$mysqli->error;
					}
					#close sql connection
					mysqli_close($mysqli);
					#set the username variable in session data
					$_SESSION['username']=$username;
					#return to the home page, or referral page
					header('Location: '.$return);
					exit();
				}else{
					$reason="please enter a valid username and password.";
				}
			}else{
				mysqli_close($mysqli);
				$reason="please enter a valid username and password.";
			}
		}else{
			$reason="please fill in all fields.";
		}
	}else{
		$reason="sage goes in all fields.";
	}
	$action="logging in";
}
#sign the user up
else if(isset($_POST['signup'])){
	#check if all required fields were filled in
	if(isset($_POST['username'])&&isset($_POST['password'])&&isset($_POST['email'])){
		#sanitize input
		$username=trim(htmlspecialchars($_POST['username']));
		$password=htmlspecialchars($_POST['password']);
		$email=htmlspecialchars($_POST['email']);
		#check if the strings are empty
		if($username!==''&&$password!==''&&$email!==''){
			#generate generate a blowfish hash with cost parameter 10, and 16 byte random salt
			$salt = sprintf("$2a$%02d$", 10).strtr(base64_encode(random_bytes(16)),'+','.');
			$hash = crypt($password, $salt);
			#sql query: make user
			#creates a new user in the database
			#returns success boolean
			$query2="call make_user('".$username."','".$email."','".$hash."')";
			#sql connection
			$mysqli = new mysqli("localhost","anon","tendies","forum");
			#check for successful connection
			if ($mysqli->connect_errno){
				echo "Failed to connect to MySQL: (".
				$msqli->connect_errno.") ".$mysqli->connect_error;
			}

			#send sql query
			if(!($res=$mysqli->query($query2,MYSQLI_STORE_RESULT))){
				echo "Creating user failed: (".$mysqli->errno.") ".$mysqli->error;
			}
			#fetch results into associative array
			$row=$res->fetch_assoc();
			#close sql connection
			mysqli_close($mysqli);
			#load the return page upon success
			if(isset($row['success'])){
				$success=$row['success'];
				if($success){
					$_SESSION['username']=$username;
					header('Location: '.$return);
					exit();
				}else{
					$reason="your username may be already taken.";
				}
			}else{
				$reason="connection error.";
			}
		}else{
			$reason="please fill in all fields.";
		}
	}else{
		$reason="sage goes in all fields.";
	}
	$action="signing up";
}
#display error messages
if(isset($reason)){?>
<div class="error">
	<div class="error-title">Sorry,</div>
	<div class="error-text">There was a problem <?php echo $action?>.<br>
	Reason: <?php echo $reason ?></div>
</div>
<?php } ?>

<!--Login Form-->
<div class="field"><form action="login.php" method="post" class="entry"><div class="title"><p class="title">Login</p></div>
<!--Username Field-->
<p><label class="field" for="username"><span class="field">*</span>username:</label><input class="replybox" type="text" name="username" maxlength="20" placeholder="required" required/></p>
<!--Password Field-->
<p><label class="field" for="username"><span class="field">*</span>password:</label><input class="replybox" type="password" name="password" maxlength="1000" placeholder="required" required/></p>
<!--Hidden Field for a flag-->
<input type="hidden" value=true name="login"/>
<!--Submit Button-->
<p><div class="submit"><input type="submit"/></div></p>
</form></div>

<!--User Signup Form-->
<div class="field"><form action="login.php" method="post" class="entry"><div class="title"><p class="title">Sign Up</p></div>
<!--Username Field-->
<p><label class="field" for="username"><span class="field">*</span>username:</label><input class="replybox" type="text" name="username" maxlength="20" placeholder="required" required/></p>
<!--Email Field-->
<p><label class="field" for="email"><span class="field">*</span>email:</label><input class="replybox" type="text" name="email" maxlength="50" placeholder="required" required/></p>
<!--Password Field-->
<p><label class="field" for="password"><span class="field">*</span>password:</label><input class="replybox" type="password" name="password" maxlength="1000" placeholder="required" required/></p>
<!--Hidden Field for a flag-->
<input type="hidden" value=true name="signup"/>
<!--Submit Button-->
<p><div class="submit"><input type="submit"/></div></p>
</form></div>

</body>
</div></html>
