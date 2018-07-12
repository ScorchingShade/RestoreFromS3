# RestoreFromS3
The purpose of this script is to:

Restore from an aws-s3 bucket as:<br /><br />
1) Restore a mysql dump file created using syncScript.sh (Install the software at https://github.com/ScorchingShade/SyncAndDumpS3).<br /><br />
2) Restore a Mongodb dump created using syncScript.sh (Install the software at https://github.com/ScorchingShade/SyncAndDumpS3).
<br /><br /><br />

RestoreFromS3 is strictly a very specific use case app. It has a specific function of automating the above mentioned tasks.
Please do not use for any other purpose other than the ones mentioned.

## Features
1) Support for local machines as well as servers.
2) Fully functional restore from specified bucket.
3) Configuration Options for Environment variables.
4) Easy to use menu driven , single session programme.

## How To Install!
Use the following command to install SyncAndDumpS3 on your ubuntu machine-<br>
`sudo snap install restore-dump-s3`
<br>
To use the software, use the command-<br>
`restore-dump-s3`



### Add Ons
Additional features include support to connect to a db on a server...uncomment the line number 152 and 206 and comment the lines 144 and 198 to include support for contacting a db on external server.

##### Command for mods
vim /snap/restore-dump-s3/<Revision-ver>/bin/Restore.sh


###### Support more development
Please add a star or write to ankushors789@gmail.com if you like the work done!! 

-Cheers<br>
---Ankush




