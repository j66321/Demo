#!/bin/bash

cd /opt/script
rm -frd backup-disk-check.sh sql/ remove_old_archive.sh remove_old_archive
mkdir -p /opt/script/remove_old_archive
cd /opt/script/remove_old_archive
cat > /opt/script/remove_old_archive/remove_old_archive.sh << EOF
#!/bin/bash
source /home/oracle/.bash_profile
rman target / cmdfile /opt/script/remove_old_archive/rcv/remove_old_archive.rcv > /opt/script/remove_old_archive/result.txt 2>&1
exit
EOF

mkdir -p /opt/script/remove_old_archive/rcv
cat > /opt/script/remove_old_archive/rcv/remove_old_archive.rcv << EOF
run {
crosscheck archivelog all;
DELETE ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-14';
}
EOF

chown -R oracle:oinstall /opt/script/remove_old_archive
chmod +x /opt/script/remove_old_archive/remove_old_archive.sh
