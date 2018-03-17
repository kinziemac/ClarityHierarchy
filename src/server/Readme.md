# README

This readme contains a list of files in the current directory and their function.

|filename:                            |function:                                                                  |
|:------------------------------------|:--------------------------------------------------------------------------|
|create_forum_schema.sql              |Mysql script containing all scripts necessary to create the forum database.|
|backup.sh                            |A bash script that backs up the database and keeps the last 4 backups.     |
|restore.sh                           |A bash script to restore a database backup.                                |
|forum_backup_cronjob                 |A crontab rule to backup the server weekly.                                |
|forum.css                            |Style sheet data for the entire website.                                   |
|account.php                          |Account management page.                                                   |
|action.php                           |Topic submission code.                                                     |
|edit.php                             |Topic/Post edit page.                                                      |
|forum.php                            |Main page. Allows the user to create a topic and shows all topics.         |
|login.php                            |User login verification, and login/signup page.                            |
|rate.php                             |Submits topic and post ratings, returns the result.                        |
|reply.php                            |Reply submission code.                                                     |
|subm_edit.php                        |Submits topic and post edits.                                              |
|topic.php                            |View a single topic and its replies. Allows the user to submit a reply.    |

The file create_forum_schema.sql is run in a Mysql or mariaDB server to create the database.
The rest of the files are hosted by an Apache (httpd) server on the same host server.
Apache relies on an installation of PHP 7 on the same host server.
Apache must be set up to use SSL, and must have a valid SSL certificate issued by a trusted certificate authority.
backup.sh should be put in '/usr/local/bin/' according to the contab rule.

