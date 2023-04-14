#!/bin/bash
backuptime=`TZ='Asia/Taipei' date +"%Y%m%d%H%M"`

function env_pick {
echo  "\tMandatory condition before running this script"
echo  "\t1. Connect to OpenVPN"
echo  "\t2. Your mac should install pg_dump & psql\n"
echo  "\t########## Choose an Bingo Environment ##########"
echo  "\t1. Dev"
echo  "\t2. Stg"
echo  "\t3. Rel"
read -rp "        Enter an option : " bingo_env
echo  "\t"

if [ "$bingo_env" == 1 ]; then
       subfolder="Dev";
       bingo_host="123.456.ap-east-1.rds.amazonaws.com"
elif [ "$bingo_env" == 2 ]; then
       subfolder="Stg";
       bingo_host="123.456.ap-east-1.rds.amazonaws.com"
elif [ "$bingo_env" == 3 ]; then
       subfolder="Rel";
       bingo_host="123.456.ap-east-1.rds.amazonaws.com"
fi
}

function user_db_pick {
echo  "\t########## Choose user and db ##########"
echo  "\t1. user:bingo , db:bingodb"
echo  "\t2. user:mgmt , db:bgmgmtdb"
read -rp "        Enter an option : " bingo_user 
echo  "\t"

if [ "$bingo_user" == 1 ]; then
       bingo_username="bingo"
       bingo_dbname="bingodb"
elif [ "$bingo_user" == 2 ]; then
       bingo_username="mgmt"
       bingo_dbname="bgmgmtdb"
fi
}

function action_pick {
echo  "\t########## Choose an action ##########"
echo  "\t1. Backup DB"
echo  "\t2. Restore DB"
read -rp "        Enter an option : " action
echo  "\t"

if [ "$action" == 1 ]; then
		read -rp "type the description for backupfile : " backup_description
              pg_dump -c -h $bingo_host -U $bingo_username $bingo_dbname > ./Backupfile/$subfolder/$bingo_dbname/"$backuptime"_"$backup_description".sql
elif [ "$action" == 2 ]; then
		read -rp "type the restore filename, such as 202303231645_First_Backup.sql : " restore_filename
		psql -h $bingo_host -U $bingo_username $bingo_dbname < ./Backupfile/$subfolder/$bingo_dbname/$restore_filename
fi 
}

#find ./Backupfile/ -name "*.sql" -ctime +14 -exec rm -rf {} \; 
env_pick
user_db_pick
action_pick

if [ "$?" == 1 ]; then
		rm ./Backupfile/$subfolder/$bingo_dbname/"$backuptime"_"$backup_description".sql
fi

