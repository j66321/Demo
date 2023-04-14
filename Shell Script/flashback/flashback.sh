#!/bin/bash
backuptime=`TZ='Asia/Taipei' date +"%Y%m%d%H%M"`

function create_restore_point {
sqlplus / as sysdba << EOF
@sql/create_point.sql
exit
EOF
}

function display_restore_point {
sqlplus / as sysdba << EOF
@sql/display_restore_point.sql
exit
EOF
}

function restore_oracle {
sqlplus / as sysdba << EOF
@sql/restore_oracle.sql
exit
EOF
}

function action_pick {
clear
echo -e "\t########## Choose an action ##########\n"
echo -e "\t1. Display Restore Point"
echo -e "\t2. Backup Oracle"
echo -e "\t3. Restore Oracle"
read -rp "        Enter an option : " action
echo -e "\taction choose ${action}"
echo -e "\t"
}

action_pick
if [ "$action" == 1 ]; then
		display_restore_point	
elif [ "$action" == 2 ]; then
		read -rp "type the description for the backup point : " description
		sed -i "s/backuptime/${backuptime}_${description}/1" sql/create_point.sql
		create_restore_point
		sed -i "s/${backuptime}_${description}/backuptime/1" sql/create_point.sql
elif [ "$action" == 3 ]; then
		display_restore_point
		read -rp "type the restore point timestamp : " restore_point
		sed -i "s/restore_point/$restore_point/1" sql/restore_oracle.sql
		lsnrctl stop
		restore_oracle
		sed -i "s/$restore_point/restore_point/1" sql/restore_oracle.sql
		lsnrctl start
else
	       	echo -e "\tPlease choose 1/2/3,thx"
fi
