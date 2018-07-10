#!/bin/bash
##################
#The purpose of the script is to--
# To Restore the snapshots on local for mysql and mongodb dumps
# 
##################

############Custom vars################################################################################
SCRIPT_STATE=$1
SQL_PATH="mysql"
MONGO_PATH="mongorestore"
#######MySql settings##################################################################################
SOURCE_BUCKET_SQL="s3://ankush-dump-3/latestmysql.gz"
TMP=`mkdir -p /tmp/Gzip && cd /tmp/Gzip`
FIND_TMP=`find /tmp/Gzip/ |xargs|awk '{print $1}'`
SQL_DIR="/tmp/Gzip/"
mysqlDIR="/tmp/Gzip/latestmysql.sql"
Db_NAME="ANKUSH_Intern_mysql"

MYSQLPASS=""
MYSQL_USER=""
MYSQL_HOST=""

#######Mongo Settings####################################################################################
SOURCE_BUCKET_Mongo="s3://ankush-dump-3/Latestmongo.tar.gz"
TMP1=`mkdir -p /tmp/Gzip1 && cd /tmp/Gzip1`
FIND_TMP1=`find /tmp/Gzip1/ |xargs|awk '{print $1}'`
Mongo_DIR="/tmp/Gzip1/"
For_TAR="/tmp/Gzip1/Latestmongo.tar.gz"
mongoDbName="ankushKaDb"

MONGO_HOST=""
MONGO_PORT=""
MONGO_USER=""
MONGO_PASS=""

################################progress bar###############################################################
progress_bar()
{
  local DURATION=$1
  local INT=0.25      # refresh interval

  local TIME=0
  local CURLEN=0
  local SECS=0
  local FRACTION=0

  local FB=2588       # full block

  trap "echo -e $(tput cnorm); trap - SIGINT; return" SIGINT

  echo -ne "$(tput civis)\r$(tput el)│"                # clean line

  local START=$( date +%s%N )

  while [ $SECS -lt $DURATION ]; do
    local COLS=$( tput cols )

    # main bar
    local L=$( bc -l <<< "( ( $COLS - 5 ) * $TIME  ) / ($DURATION-$INT)" | awk '{ printf "%f", $0 }' )
    local N=$( bc -l <<< $L                                              | awk '{ printf "%d", $0 }' )

    [ $FRACTION -ne 0 ] && echo -ne "$( tput cub 1 )"  # erase partial block

    if [ $N -gt $CURLEN ]; then
      for i in $( seq 1 $(( N - CURLEN )) ); do
        echo -ne \\u$FB
      done
      CURLEN=$N
    fi

    # partial block adjustment
    FRACTION=$( bc -l <<< "( $L - $N ) * 8" | awk '{ printf "%.0f", $0 }' )

    if [ $FRACTION -ne 0 ]; then 
      local PB=$( printf %x $(( 0x258F - FRACTION + 1 )) )
      echo -ne \\u$PB
    fi

    # percentage progress
    local PROGRESS=$( bc -l <<< "( 100 * $TIME ) / ($DURATION-$INT)" | awk '{ printf "%.0f", $0 }' )
    echo -ne "$( tput sc )"                            # save pos
    echo -ne "\r$( tput cuf $(( COLS - 6 )) )"         # move cur
    echo -ne "│ $PROGRESS%"
    echo -ne "$( tput rc )"                            # restore pos

    TIME=$( bc -l <<< "$TIME + $INT" | awk '{ printf "%f", $0 }' )
    SECS=$( bc -l <<<  $TIME         | awk '{ printf "%d", $0 }' )

    # take into account loop execution time
    local END=$( date +%s%N )
    local DELTA=$( bc -l <<< "$INT - ( $END - $START )/1000000000" \
                   | awk '{ if ( $0 > 0 ) printf "%f", $0; else print "0" }' )
    sleep $DELTA
    START=$( date +%s%N )
  done

  echo $(tput cnorm)
  trap - SIGINT
}
###############################################################################################################################








##restore your mysql dump--------------
function mysqlRestore(){


	if [ $FIND_TMP != $PWD ];
	then 

		printf "Switching Directories temporarily to do some work here.....................\n"
		echo $TMP

		printf "Downloading Files to Local Directory....................\n"
		progress_bar 5
		echo `aws s3 cp $SOURCE_BUCKET_SQL $SQL_DIR`
		if [ $? -eq 0 ];then	
			printf "files Downloaded Successfully\n"
		else
 			echo "Error in Contacting aws...program will terminate"
 			exit 1
		fi

		printf "Extracting the dump file\n"
		gunzip -k $SQL_DIR'latestmysql.gz'
		if [ $? -eq 0 ];then
			progress_bar 2	
			printf "File extracted Successfully\n"
		else
 			echo "Error in extraction...program will terminate"
 			exit 1
		fi
		
		mv $SQL_DIR'latestmysql' $SQL_DIR'latestmysql.sql' &&  sed -i -e '1iUse '"$Db_NAME"' \' $SQL_DIR'latestmysql.sql' 
		
		printf "Restoring the dump to your mysqldb named $Db_NAME......................\n"
		progress_bar 2
		sudo $SQL_PATH < $SQL_DIR'latestmysql.sql'
		if [ $? -eq 0 ];then
		printf "Restored dump Successfully\n"
		else
 			echo "Error in restoring dump...program will terminate"
 			exit 1
		fi
		##################################the complete MySql restore command#####################################
		#sudo mysql -u $MYSQL_USER -p $MYSQLPASS -h $MYSQL_HOST< $SQL_DIR'latestmysql.sql'
		#########################################################################################################

		printf "Removing Temporary Folder and files......................\n"
		progress_bar 1
		rm -r /tmp/Gzip/
		
		printf "##############################################Successfull##############################################\n\n\n"

	fi
}

##restore your mongo dump--------------
function mongolRestore(){


	if [ $FIND_TMP1 != $PWD ];
	then 
		printf "Switching Directories temporarily to do some work here.....................\n"
		echo $TMP1
		
		printf "Downloading Files to Local Directory.\n"
		progress_bar 5
		echo `aws s3 cp $SOURCE_BUCKET_Mongo $Mongo_DIR`
		if [ $? -eq 0 ];then
			printf "Files Downloaded Successfully\n"
		else
 			echo "Error in Contacting aws...program will terminate"
 			exit 1
		fi
		printf "Extracting the dump file.\n"
		progress_bar 2
		tar -xzvf $For_TAR --directory $Mongo_DIR
		if [ $? -eq 0 ];then	
			printf "Extraction completed Successfully\n"
		else
 			echo "Error in Extraction...program will terminate"
 			exit 1
		fi
		########The extracted file has the database created in MongoDumps folder from SyncScript, comment out the below line if you
		########don't want to move to the MongoDumps folder to access the dump file
		cd $Mongo_DIR"MongoDumps"
		
		####delete "MongoDumps/ if you don't have any MongoDumps folder when extracting the tar"
		printf "Restoring the dump to your mysqldb named $Db_NAME......................\n"
		progress_bar 2
		$MONGO_PATH --db $mongoDbName $Mongo_DIR"MongoDumps/"$mongoDbName"/"
		if [ $? -eq 0 ];then	
			printf "Dump restored Successfully\n"
		else
 			echo "Error in restoring dump...program will terminate"
 			exit 1
		fi
		####################Mongo Restore with all the parameters, for a host server on different machine#############################################################
		#mongorestore --host $MONGO_HOST --port $MONGO_PORT --username $MONGO_USER --password '"$MONGO_PASS"' --db $mongoDbName $Mongo_DIR"MongoDumps/"$mongoDbName"/"
		##############################################################################################################################################################

		printf "Removing Temporary Folder and files......................\n"
		progress_bar 1
		rm -r /tmp/Gzip1/		
		
		printf "##############################################Successfull##############################################\n\n\n"		
		
	fi
}


case $SCRIPT_STATE in 
	"restoremysql")
		mysqlRestore
	;;
	"restoremongo")
		mongolRestore
	;;
	 *)
  	;;
esac