shutdown immediate
startup mount
flashback database to restore point "F_restore_point";
alter database open RESETLOGS;
