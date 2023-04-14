#!/bin/bash

function gcp_list_instance() {
cd ~/Desktop/Git/weeklyreport/cost_estimate
for production in {api,blj,client,datacenter,dev,dragon,in,itmanage,ky110,ky34,ky508,kygpk,kyt,kyz,lc,ly,ly2,mp,yl34,xsj}
do
    gcloud config set project project-${production}-product
    gcloud compute instances list --filter="status=('RUNNING')" | awk -F " " 'NR == 1 {next} {print $1,$2,$3}' >> gcp_instance_list.txt
done

###xsj2 and yldf project id is different
gcloud config set project project-kydf-procuct
gcloud compute instances list --filter="status=('RUNNING')" | awk -F " " 'NR == 1 {next} {print $1,$2,$3}' >> gcp_instance_list.txt

gcloud config set project project-xsj2-product-295715
gcloud compute instances list --filter="status=('RUNNING')" | awk -F " " 'NR == 1 {next} {print $1,$2,$3}' >> gcp_instance_list.txt

###diff
rm -f gcp_week_diff.txt
diff gcp_instance_list.txt gcp_instance_list_lastweek.txt >> gcp_week_diff.txt
mv -f gcp_instance_list.txt gcp_instance_list_lastweek.txt

###change pdf to jpeg
cd ~/Desktop/
sips -s format jpeg GCP-Cost-Estimate.pdf --out "GCP-Cost-Estimate.jpeg"
cp -f GCP-Cost-Estimate.jpeg Git/weeklyreport/cost_estimate/pics/gcp.pics/GCP-Cost-Estimate.jpeg
cd ~/Desktop/
rm -f GCP-Cost-Estimate.pdf GCP-Cost-Estimate.jpeg

###git push
cd ~/Desktop/Git/weeklyreport/cost_estimate
git add .
git commit -m 'upload gcp cost estimate for lastweek'
git push
}

function gcp_remove_instance_protection() {
for machine in `gcloud compute instances list --filter="status=('TERMINATED')" | awk -F " " 'NR == 1 {next} {print $1}'`
do
gcloud compute instances update $machine --no-deletion-protection
done
}


function gcp_add_firewallpolicy() {
for production in {api,blj,client,datacenter,dev,dragon,in,itmanage,ky110,ky34,ky508,kydf,kygpk,kyt,kyz,lc,ly,ly2,ly3,mp,xsj2-product-295715,yl34}
do
    gcloud config set project project-${production}-product
    gcloud compute firewall-rules create "vpc-prod-t5-out" --action=ALLOW --rules=tcp:80,tcp:443 --destination-ranges="113.196.37.195/32,113.196.77.2/32" --direction=EGRESS --network=${production}-prod-vpc
#gcloud compute firewall-rules create "vpc-prod-s1-out" --action=ALLOW --rules=tcp:443 --destination-ranges="54.238.218.218/32,13.115.156.204/32,52.193.46.162/32,52.219.12.71/32,52.219.68.95/32,18.178.154.223/32,18.177.117.231/32,18.178.75.212/32" --direction=EGRESS --network=xsj2-prod-vpc
done
}

function gcp_update_firewallpolicy() {
for production in {api,blj,client,datacenter,dev,dragon,in,itmanage,ky110,ky34,ky508,kygpk,kyt,kyz,lc,ly,ly2,ly3,mp,yl34}
do
    gcloud config set project project-${production}-product
    gcloud compute firewall-rules update "vpc-prod-s1-out" --rules=tcp:443 --destination-ranges="18.176.151.131/32,13.115.156.204/32,52.193.46.162/32,52.219.12.71/32,52.219.68.95/32,18.178.154.223/32,18.177.117.231/32,18.178.75.212/32"
done

    gcloud config set project project-kydf-procuct
    gcloud compute firewall-rules update "vpc-prod-s1-out" --rules=tcp:443 --destination-ranges="18.176.151.131/32,13.115.156.204/32,52.193.46.162/32,52.219.12.71/32,52.219.68.95/32,18.178.154.223/32,18.177.117.231/32,18.178.75.212/32" 

    gcloud config set project project-xsj2-product-295715
    gcloud compute firewall-rules update "vpc-prod-s1-out" --rules=tcp:443 --destination-ranges="18.176.151.131/32,13.115.156.204/32,52.193.46.162/32,52.219.12.71/32,52.219.68.95/32,18.178.154.223/32,18.177.117.231/32,18.178.75.212/32"

}


function menu {
clear echo 
echo  "\t**********GCP 腳本清單**********n"
echo  "\t1. gcp_cost_estimate"
echo  "\t2. gcp remove instance removal protection"
echo  "\t3. gcp add team t5 firewall policy"
echo  "\t4. gcp update s1 firewall policy"
echo  "\t0. Exit menu\n\n"
echo  "\tEnter an option: "
read -n 1 option
}

while [ 1 ]
do 
menu
case $option in
0)
	break ;;
1)
	echo -en "\t"
	echo -en "\t"; read -p "Did you download pdf file from Data Studio ? (yes/no):" action
	if [ "$action" == "yes" ]; then
		gcp_list_instance
	else
		exit 1
	fi
	;;

2)
        echo -en "\t"
        echo -en "\t"; read -p "Are you sure to remove all teminated instances protection from project ? (yes/no):" action
        if [ "$action" == "yes" ]; then
                gcp_remove_instance_protection
        else
                exit 1
        fi
        ;;

3)
	echo -en "\t"
        echo -en "\t"; read -p "Are you sure to add team t5 whitelist to all gcp project ? (yes/no):" action
	if [ "$action" == "yes" ]; then
		gcp_add_firewallpolicy
	else
                exit 1
        fi
        ;;

4)
        echo -en "\t"
        echo -en "\t"; read -p "Are you sure to update s1 whitelist to all gcp project ? (yes/no):" action
        if [ "$action" == "yes" ]; then
                gcp_update_firewallpolicy
        else
                exit 1
        fi
        ;;

*)
clear
echo -en "\n\n\tSorry, wrong selection" ;;
esac

echo -en "\n\n\tHit any key to continue Or Ctrl + C"
read -n 1 line
done
clear
