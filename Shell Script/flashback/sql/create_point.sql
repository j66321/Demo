create restore point F_backuptime;
select * from (select SCN,TIME,GUARANTEE_FLASHBACK_DATABASE,NAME from v$restore_point order by TIME DESC) where TIME >= trunc(sysdate) - 7;
