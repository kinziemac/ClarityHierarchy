create database forum;
use forum;

/* users table with
fields:
username	unique identifier for user
email		user's email address
secret		hash of user's password
*/
create table users(
	username varchar(20) not null,
	email varchar(50) not null,
	secret varchar(64) not null,
	primary key(username)
);

/* topics table with
fields:
topic_id	unique identifier for topic
username	unique identifier for topic's poster
topic_date	date topic made in seconds since 01-01-1970 (unix time)
topic_title	topic title text
topic_text	topic body text
last_edit	date of last modification to the topic
last_edited_by	username of user who last modified the topic
*/
create table topics(
	username varchar(20),
	topic_id int not null auto_increment,
	topic_date int not null, 
	topic_title varchar(50) not null,
	topic_text varchar(1000) not null,
	last_edit int,
	last_edited_by varchar(20),
	primary key(topic_id),
	foreign key(username)
		references users(username)
			on delete cascade
			on update cascade
);

/* posts table with
fields:
post_id		unique identifier for post
topic_id	unique identifier for post's topic
username	unique identifier for post's poster
post_date	date post made in seconds since 01-01-1970 (unix time)
post_title	post title text
post_text	post body text
last_edit	date of last modification to the post
last_edited_by	username of user who last modified the post
*/
create table posts(
	username varchar(20),
	topic_id int,
	post_id int not null auto_increment,
	post_date int not null,
	post_title varchar(50),
	post_text varchar(1000) not null,
	last_edit int,
	last_edited_by varchar(20),
	primary key(post_id),
	foreign key(username)
		references users(username)
		on delete cascade
		on update cascade,
	foreign key(topic_id)
		references topics(topic_id)
		on delete cascade
		on update cascade
);

/* topic_ratings table with
fields:
topic_id	unique identifier for topic
username	unique identifier for username of user who rated
*/
create table topic_ratings(
	topic_id int not null,
	username varchar(20) not null,
	primary key(topic_id,username),
	foreign key(topic_id)
		references topics(topic_id)
			on delete cascade,
	foreign key(username)
		references users(username)
			on delete cascade
);

/* post_ratings table with
fields:
post_id		unique identifier for topic
username	unique identifier for username of user who rated
*/
create table post_ratings(
	post_id int not null,
	username varchar(20) not null,
	primary key(post_id,username),
	foreign key(post_id)
		references posts(post_id)
			on delete cascade,
	foreign key(username)
		references users(username)
			on delete cascade
);

delimiter //

/* procedure to create a new user with
fields:
username	unique identifier for user
email		user's email address
secret		hash of user's password
returns:
success		whether or not succeeded in creating a user
*/
create procedure make_user(
	username varchar(20),
	email varchar(50),
	secret varchar(64))
language sql deterministic sql security definer
comment 'Create a user.'
begin
/*	declare user_exists int;
	set user_exists=((select count(1) from users u where u.username=username));*/
	declare success bool;
	set success = if(
		(select count(1) from users u where u.username=username),false, true
	);
	if(success) then
		insert into users(username,email,secret) values(username,email,secret);
	end if;
	select success;
end//

/* procedure to set the user's password hash with
fields:
username	unique identifier for a user
secret		user's new password hash
*/
create procedure set_user_secret(
	username varchar(20),
	secret varchar(64))
language sql deterministic sql security definer
comment 'Update users\'s password hash.'
begin
	update users u
	set u.secret=secret
	where u.username=username;
end//

/* procedure to get the user's password hash with
fields:
username	unique identifier for a user
returns:
secret		user's password hash
*/
create procedure get_user_secret(
	username varchar(20))
language sql deterministic sql security definer
comment 'Get users\'s password hash.'
begin
	select secret from users u where u.username=username;
end//

/* procedure to create a post with
fields:
username	unique identifier for user
topic_id	unique identifier for topic
post_title	post title text
post_text	post body text
returns:
post_id		unique identifier for post
*/
create procedure make_post(
	username varchar(20),
	topic_id int,
	post_title varchar(50),
	post_text varchar(1000))
language sql deterministic sql security definer
comment 'Make a post.'
begin
	declare post_id int;
	insert into posts(topic_id,post_date,post_title,username,post_text)
	values(topic_id,unix_timestamp(now()),post_title,username,post_text);
	set post_id = LAST_INSERT_ID();
	select post_id;
end//

/* procedure to create a topic with
fields:
username	unique identifier for user
topic_title	topic title text
topic_text	topic body text
returns:
topic_id	unique identifier for topic
*/
create procedure make_topic(
	username varchar(20),
	topic_title varchar(50),
	topic_text varchar(1000))
language sql deterministic sql security definer
comment 'Create a topic.'
begin
	declare LID int;
	insert into topics(topic_date,topic_title,username,topic_text)
	values(unix_timestamp(now()),topic_title,username,topic_text);
	set LID = LAST_INSERT_ID();
	select LID as topic_id, 'OK' as msg;
end//

/* procedure to list all topics with
fields:
nothing
returns:
username	unique identifier for a user
topic_id	unique identifier for a topic
topic_date	date topic was posted
topic_title	topic title text
*/
create procedure list_topics()
language sql deterministic sql security definer
comment 'List all topics.'
begin
	select username, topic_id, topic_date, topic_title
	from topics
	order by topic_id desc;
end//

/* procedure to list all topics by a single user with
fields:
username	unique identifier for a user
returns:
topic_id	unique identifier for a topic
topic_date	date topic was posted
topic_title	topic title text
*/
create procedure list_topics_by_user(
	username varchar(20))
language sql deterministic sql security definer
comment 'List all topics by a single user.'
begin
	select topic_id, topic_date, topic_title
	from topics t
	where username=t.username;
end//

/* procedure to list all posts by a single user with
fields:
username	unique identifier for a user
returns:
post_id		unique identifier for a post
post_date	date post was posted
post_title	post title text
*/
create procedure list_posts_by_user(
	username varchar(20))
language sql deterministic sql security definer
comment 'List all posts by a single user.'
begin
	select post_id, post_date, post_title from posts p
	where username=p.username;
end//

/* procedure to list all posts in a single topic with
fields:
topic_id	unique identifier for a topic
returns:
username	unique identifier for a user
post_id		unique identifier for a post
post_date	date post was posted
post_title	post title text
post_text	post text body
rating		user rating of post
last_edit	date post was last edited
last_edited_by	username of user who last edited the post
*/
create procedure list_posts_by_topic(
	topic_id int)
language sql deterministic sql security definer
comment 'List all posts in a topic.'
begin
	select
		username,post_id, post_date, post_title, post_text,
		get_post_rating(post_id) as rating, last_edit, last_edited_by
	from posts p
	where topic_id=p.topic_id;
end//

/* procedure to get a topic with
fields:
topic_id	unique identifier for a topic
returns:
username	unique identifier for a user
topic_id	unique identifier for a topic
topic_date	date post was posted
topic_title	topic title text
topic_text	topic text body
rating		user rating of topic
last_edit	date ropic was last edited
last_edited_By	username of user who last edited the topic
*/
create procedure get_topic(
	topic_id int)
language sql deterministic sql security definer
comment 'Get a topic post.'
begin
	select 
		username, topic_id, topic_date, topic_title, topic_text,
		get_topic_rating(topic_id) as rating, last_edit, last_edited_by
	from topics t
	where topic_id=t.topic_id;
end//

/* procedure to update a topic with
fields:
topic_id	unique identifier for the topic to update
topic_title	new title for the topic
topic_text	new text body for the topic
returns:
nothing
*/
create procedure update_topic(
	topic_id int,
	topic_title varchar(50),
	topic_text varchar(1000),
	username varchar(20))
language sql deterministic sql security definer
comment 'Update topic data'
begin
	update topics t
	set
		t.topic_title=topic_title, t.topic_text=topic_text,
		t.last_edited_by=username, t.last_edit=unix_timestamp(now())
	where t.topic_id=topic_id;
end//

/* procedure to update a post with
fields:
post_id		unique identifier for the post to update
post_title	new title for the post
post_text	new text body for the post
returns:
nothing
*/
create procedure update_post(
	post_id int,
	post_title varchar(50),
	post_text varchar(1000),
	username varchar(20))
language sql deterministic sql security definer
comment 'Update post data'
begin
	update posts p
	set
		p.post_title=post_title, p.post_text=post_text,
		p.last_edited_by=username, p.last_edit=unix_timestamp(now())
	where p.post_id=post_id;
end//

/* procedure to add to the rating of a topic with
fields:
topic_id	unique identifier for the topic to rate
returns:
rating		resultant rating
*/
create procedure rate_topic(
	topic_id int,
	username varchar(20))
language sql deterministic sql security definer
comment 'Rate a topic.'
begin
	declare rating_exists int;
	set rating_exists = if(
		(select count(1) from topic_ratings r
			where r.username=username and r.topic_id=topic_id), false, true);
	if(rating_exists) then
		insert into topic_ratings(topic_id,username) values(topic_id,username);
	else
		delete from topic_ratings where topic_ratings.topic_id=topic_id and topic_ratings.username=username;
	end if;
	select get_topic_rating(topic_id) as rating;
end//

/* procedure to add to the rating of a post with
fields:
post_id		unique identifier for the post to rate
returns:
rating		resultant rating
*/
create procedure rate_post(
	post_id int,
	username varchar(20))
language sql deterministic sql security definer
comment 'Rate a post.'
begin
	declare rating_exists int;
	set rating_exists = if(
		(select count(1) from post_ratings r
			where r.username=username and r.post_id=post_id), false, true);
	if(rating_exists) then
		insert into post_ratings(post_id,username) values(post_id,username);
	else
		delete from post_ratings where post_ratings.post_id=post_id and post_ratings.username=username;
	end if;
	select get_post_rating(post_id) as rating;
end//

create procedure delete_user(
	username varchar(20))
language sql deterministic sql security definer
begin
	delete from users where users.username=username;
end//

/* procedure to get a range of replies from a topic with
fields:
topic_id		unique identifier for a topic
reply_offset	number of replies to skip over
num_replies		maximum number of replies to get
returns:		
username		unique identifier for a user
post_id			unique identifier for a post
post_date		date post was posted
post_title		post title text
post_text		post text body
rating			user rating of post
last_edit		date post was last edited
last_edited_by	username of user who last edited the post
*/
create procedure get_some_replies_by_topic(
	topic_id int,
	reply_offset int,
	num_replies int)
language sql deterministic sql security definer
comment 'Get some replies.'
begin
	select
		username, post_id, post_date, post_title, post_text,
		get_post_rating(post_id) as rating, last_edit, last_edited_by
	from posts p
	where p.topic_id=topic_id
	order by p.post_id
	limit reply_offset, num_replies;
end//

/* procedure to get the reply count of a topic with
fields:
topic_id	unique identifier for a topic
returns:
num_replies	reply count of the topic
*/
create procedure get_num_replies(
	topic_id int)
language sql deterministic sql security definer
comment 'Get number of replies.'
begin
	select count(*) as num_replies
	from posts p
	where p.topic_id=topic_id;
end//

/* procedure to get the topic_id from a post with
fields:
post_id		unique identifier for a post
returns:
topic_id	unique identifier for a topic
*/
create procedure get_topic_from_post(
	post_id int)
language sql deterministic sql security definer
comment 'Get which topic a post belongs to.'
begin
	select topic_id
	from posts p
	where p.post_id=post_id;
end//

/* procedure to get a post's ranking within its topic with:
fields:
post_id		unique identifier for a post
topic_id	unique identifier for a topic
returns:
rank		the post's ranking within its topic
*/
create procedure get_post_rownumbers(
	post_id int,
	topic_id int)
language sql deterministic sql security definer
comment 'Get get post\'s ranking within the topic.'
begin
	set @row_num=0;
	create temporary table if not exists temptable as(
		select
			(@row_num:=@row_num+1) as rank,p.post_id
		from posts p
		where p.topic_id=topic_id
	);
	select rank from temptable where temptable.post_id=post_id;
end//

/* procedure to reset the database to a default state */
create procedure reset()
language sql deterministic sql security definer
begin
	delete from topics;
	delete from users;
	alter table posts auto_increment = 1;
	alter table topics auto_increment = 1;
	insert into users(username,email,secret) values("anonymous user","<none>","<none>");
end//

/* procedure to set the user's password and email with
Fields:
username	unique identifier for a user
secret		new password hash
email		new email string
*/
create procedure set_user_secret_and_email(
	username varchar(20),
	secret varchar(64),
	email varchar(50))
language sql deterministic sql security definer
begin
	update users u
	set u.secret=secret, u.email=email
	where u.username=username;
end//

/* function to calculate a post's rating with
Fields:
post_id		unique identifier for a post
Returns:	The post's total rating.
*/
create function get_topic_rating(topic_id int)
returns int
deterministic
begin
	declare res int;
	select count(1) into res from topic_ratings r
	where r.topic_id=topic_id group by r.topic_id;
	if(res is null) then
		return 0;
	else
		return res;
	end if;
end//

/* function to calculate a post's rating with
Fields:
post_id		unique identifier for a post
Returns:	The post's total rating.
*/
create function get_post_rating(post_id int)
returns int
deterministic
begin
	declare res int;
	select count(1) into res from post_ratings r
	where r.post_id=post_id group by r.post_id;
	if(res is null) then
		return 0;
	else
		return res;
	end if;
end//

/*grant permissions on these procedures for PHP to access them*/
GRANT EXECUTE ON PROCEDURE `forum`.`set_user_secret` TO 'anon'@'localhost';
GRANT EXECUTE ON PROCEDURE `forum`.`list_posts_by_topic` TO 'anon'@'localhost';
GRANT EXECUTE ON PROCEDURE `forum`.`list_topics_by_user` TO 'anon'@'localhost';
GRANT EXECUTE ON PROCEDURE `forum`.`get_topic` TO 'anon'@'localhost';
GRANT EXECUTE ON PROCEDURE `forum`.`update_topic` TO 'anon'@'localhost';
GRANT EXECUTE ON PROCEDURE `forum`.`get_post_rownumbers` TO 'anon'@'localhost';
GRANT EXECUTE ON PROCEDURE `forum`.`get_topic_from_post` TO 'anon'@'localhost';
GRANT EXECUTE ON PROCEDURE `forum`.`list_topics` TO 'anon'@'localhost';
GRANT EXECUTE ON PROCEDURE `forum`.`get_user_secret` TO 'anon'@'localhost';
GRANT EXECUTE ON PROCEDURE `forum`.`make_user` TO 'anon'@'localhost';
GRANT EXECUTE ON PROCEDURE `forum`.`set_user_secret_and_email` TO 'anon'@'localhost';
GRANT EXECUTE ON PROCEDURE `forum`.`list_posts_by_user` TO 'anon'@'localhost';
GRANT EXECUTE ON PROCEDURE `forum`.`rate_post` TO 'anon'@'localhost';
GRANT EXECUTE ON PROCEDURE `forum`.`get_num_replies` TO 'anon'@'localhost';
GRANT EXECUTE ON PROCEDURE `forum`.`update_post` TO 'anon'@'localhost';
GRANT EXECUTE ON PROCEDURE `forum`.`get_some_replies_by_topic` TO 'anon'@'localhost';
GRANT EXECUTE ON PROCEDURE `forum`.`make_topic` TO 'anon'@'localhost';
GRANT EXECUTE ON PROCEDURE `forum`.`make_post` TO 'anon'@'localhost';
GRANT EXECUTE ON PROCEDURE `forum`.`rate_topic` TO 'anon'@'localhost';

set foreign_key_checks = 1;

