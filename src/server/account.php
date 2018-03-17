<!--Page Scaling for Mobile Browsers-->
<meta name="viewport" content="width=device-width, initial-scale=0.6, maximum-scale=1.0, user-scaleable=yes" />
<html><div class="margins">
<head>
<!--Sitewide Stylesheet-->
<link rel="stylesheet" href="forum.css">
<title>Clarity Forum: Account Management</title>
<a href="forum.php"><div class="heading"><div class="nav_title">Clarity Project Forum [Return]</div></div></a>
</head>

<body>
<!--Page Heading-->
<hr size=1 width=100% align=left noshade>
<div class="heading"><div class="nav_title">ACCOUNT MANAGEMENT PAGE</div></div>
<hr size=1 width=100% align=left noshade>

<?php
#start session storage
session_start();

#failsafe for empty session data, user must be logged in to access this page
if(!isset($_SESSION['username'])){
	header('Location: forum.php');
	exit();
}

#Delete user account
if(isset($_POST['delete'])){
	$username=$_SESSION['username'];
	$password=htmlspecialchars($_POST['password']);
	if($password!==''&&isset($_POST['password'])){
		$query1="call get_user_secret('".$username."')";
		$mysqli = new mysqli("localhost","anon","tendies","forum");
		if ($mysqli->connect_errno){
			echo "Failed to connect to MySQL: (".
			$msqli->connect_errno.") ".$mysqli->connect_error;
		}
		if(!($res=$mysqli->query($query1,MYSQLI_STORE_RESULT))){
			echo "Login failed: (".$mysqli->errno.") ".$mysqli->error;
		}
		$row=$res->fetch_assoc();
		$mysqli->next_result();
		$mysqli->next_result();
		if(isset($row['secret'])){
			$secret=$row['secret'];
			$hash = crypt($password, $secret);
			if (hash_equals($secret,crypt($password,$secret))) {
				$query3="call delete_user('".$username."')";
				if(!($res=$mysqli->query($query3,MYSQLI_STORE_RESULT))){
					echo "User deletion failed: (".$mysqli->errno.") ".$mysqli->error;
				}
				mysqli_close($mysqli);
				unset($_SESSION['username']);
				$_SESSION['account_deleted']=true;
				header('Location: forum.php');
				exit();
			}else{
				$reason="please enter a valid password.";
			}
		}else{
			mysqli_close($mysqli);
			$reason="please enter a valid password.";
		}
	}else{
		$reason="please fill in all fields.";
	}
	$action="deleting your account";
}
#Change user password, check if all required fields are filled in
else if(isset($_POST['passwd'])&&isset($_POST['password'])&&isset($_POST['new_pass'])){
	#sanitize user input
	$password=htmlspecialchars($_POST['password']);
	$new_pass=htmlspecialchars($_POST['new_pass']);
	$username=$_SESSION['username'];
	#check if the strings are empty
	if($password!==''&&$new_pass!==''){
		#sql query: get user secret
		#returns the stored password hash for the given user
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
		#fetch result into an array
		$row=$res->fetch_assoc();
		#skip over empty results
		$mysqli->next_result();
		$mysqli->next_result();
		#check if there is a password
		if(isset($row['secret'])){
			$secret=$row['secret'];
			$hash = crypt($password, $secret);
			#validate the user's password
			if (hash_equals($secret,crypt($password,$secret))) {
				#calculate new salted password hash
				$newsalt = sprintf("$2a$%02d$", 10).strtr(base64_encode(random_bytes(16)),'+','.');
				$newhash = crypt($new_pass, $newsalt);
				#sql query: set user secret
				#sets the user's hashed password and email for the given username
				$query3="call set_user_secret('".$username."','".$newhash."')";
				#send sql query
				if(!($res=$mysqli->query($query3,MYSQLI_STORE_RESULT))){
					echo "Password change failed: (".$mysqli->errno.") ".$mysqli->error;
				}
				#close sql connection
				mysqli_close($mysqli);
				$success="password was changed";
			}else{
				$reason="please enter a valid password.";
			}
		}else{
			mysqli_close($mysqli);
			$reason="something went wrong.";
		}
	}else{
		$reason="please fill in all fields.";
	}
	$action="changing your password";
}
#Change user email, check if all required fields are filled in
else if(isset($_POST['email'])&&isset($_POST['password'])){
	#sanitize the user input
	$password=htmlspecialchars($_POST['password']);
	$email=htmlspecialchars($_POST['new_email']);
	$username=$_SESSION['username'];
	#check if the strings are empty
	if($password!==''&&$email!==''){
		
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
		#fetch the results into an array
		$row=$res->fetch_assoc();
		#skip over empty results
		$mysqli->next_result();
		$mysqli->next_result();
		#validate the user's password
		if(isset($row['secret'])){
			$secret=$row['secret'];
			$hash = crypt($password, $secret);
			#check if the password matches the hash
			if (hash_equals($secret,crypt($password,$secret))) {
				#calculate new password hash
				$newsalt = sprintf("$2a$%02d$", 10).strtr(base64_encode(random_bytes(16)),'+','.');
				$newhash = crypt($password, $newsalt);
				#sql query: set user secret and email
				#sets the user's hashed password and email for the given username
				$query4="call set_user_secret_and_email('".$username."','".$newhash."','".$email."')";
				#send sql query
				if(!($res=$mysqli->query($query4,MYSQLI_STORE_RESULT))){
					echo "Email change failed: (".$mysqli->errno.") ".$mysqli->error;
				}
				#close sql connection
				mysqli_close($mysqli);
				$success="email was changed";
			}else{
				$reason="please enter a valid password.";
			}
		}else{
			mysqli_close($mysqli);
			$reason="please enter a valid password.";
		}
	}else{
		$reason="please fill in all fields.";
	}
	$action="changing your email";
}

#display error message
if(isset($reason)){ ?>
<div class="error"><div class="error-title">Sorry:</div>
<div class="error-text">There was a problem <?php echo $action?>.<br>Reason: <?php echo $reason ?></div>
</div>
<?php }
# display success message
if(isset($success)){ ?>
<div class="success"><div class="success-title">Success:</div>
<div class="success-text">Your <?php echo $success ?> successfully!</div>
</div>
<?php } ?>

<!--Account Deletion Form-->
<div class="field"><form action="account.php" method="post" class="entry"><div class="title"><p class="title">Delete account</p></div>
<!--Username Field-->
<p><label class="field" for="username">username:</label><input class="replybox" type="text" name="username" maxlength="20" value=<?php echo $_SESSION['username']?> disabled/></p>
<!--Password Field-->
<p><label class="field" for="password"><span class="field">*</span>password:</label><input class="replybox" type="password" name="password" maxlength="255" placeholder="required" required/></p>
<!--Hidden Field for a Flag-->
<input type="hidden" value=true name="delete"/>
<!--Submission Button-->
<p><div class="submit"><input type="submit"/></div></p>
</form></div>

<!--Password Change Form-->
<div class="field"><form action="account.php" method="post" class="entry"><div class="title"><p class="title">Change password</p></div>
<!--Old Password Field-->
<p><label class="field" for="old_password"><span class="field">*</span>current:</label><input class="replybox" type="password" name="password" maxlength="255" placeholder="required" required/></p>
<!--New Password Field-->
<p><label class="field" for="new_pass"><span class="field">*</span>new:</label><input class="replybox" type="password" name="new_pass" maxlength="255" placeholder="required" required/></p>
<!--Hidden Field for a Flag-->
<input type="hidden" value=true name="passwd"/>
<!--Submission Button-->
<p><div class="submit"><input type="submit"/></div></p>
</form></div>

<!--Email Change Form-->
<div class="field"><form action="account.php" method="post" class="entry"><div class="title"><p class="title">Change email</p></div>
<!--Email Field-->
<p><label class="field" for="email"><span class="field">*</span>new email:</label><input class="replybox" type="text" name="new_email" maxlength="50" placeholder="required" required/></p>
<!--Password Field-->
<p><label class="field" for="password"><span class="field">*</span>password:</label><input class="replybox" type="password" name="password" maxlength="255" placeholder="required" required/></p>
<!--Hidden Field for a Flag-->
<input type="hidden" value=true name="email"/>
<!--Submission Button-->
<p><div class="submit"><input type="submit"/></div></p>
</form></div>

</body>
</div></html>
