#!/bin/bash

# OWNER_ID="762510625864"
#colors
GREEN='\033[0;32m'      #  ${GREEN}
YELLOW='\033[0;33m'     #  ${YELLOW} 
NORMAL='\033[0m'      #  ${NORMAL} 
# 7 * 24 * 60 *60 = 604 800
SECOUNDS_IN_7DAYS=604800
#DATE_START=`date +"%s"`
DATE_START=$(date +%s)

##### Part 1 - create an AMI of the EC2 instances for backup based on tag “Backup”
D=$(date  +%d)
M=$(date +%m)
Y=$(date +%Y)
H=$(date  +%H)
Mn=$(date +%M)
Mnts=$((10#${H}*60+10#${Mn}))
# echo «Параметр День $D  Месяц $M Год  $Y Минуты $Mnts»

# get existing INSTANCES IDs 
INSTANCES_LIST=$(aws ec2 describe-instances --filters "Name=tag:Backup,Values=true" | grep -P -o --regexp="i-\w{17}")
echo « ID INSTANCES  $INSTANCES_LIST  »

# create AMI 
for INSTANCE_ID in $INSTANCES_LIST; do   
	# echo «Параметр instance $INSTANCE_ID  »
	aws ec2  create-image --instance-id $INSTANCE_ID --name "$Y$M$D$Mnts$INSTANCE_ID" --no-reboot
done
OWNER_ID=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID | grep OwnerId | cut -f 4 -d'"')


## part 2 -3 - Delete old AMI (AMIs older than 7 days) and multicolor output
# get existing images IDs and appropriate snapshot IDs 
echo « Sometimes updating the list of AMI occurs with a delay on the server, then there will not be green lines ...  »
sleep 10 
AMI_LIST=$(aws ec2 describe-images --owners $OWNER_ID | grep -P -o --regexp="ami-\w{8}|snap-\w{17}")
echo « full List of AMIs and Snapshots $AMI_LIST  »

# create AMIs array which contains also snapshot IDs in 1,3,5... positions
AMI_ARRAY=()
for p in $AMI_LIST; do   
	AMI_ARRAY=("${AMI_ARRAY[@]}" "$p")
done

for (( i=0; i < ${#AMI_ARRAY[@]}; i=i+2 ))
do
	DATE_AMI=$(aws ec2 describe-images --image-ids ${AMI_ARRAY[$i]} | grep CreationDate  | cut -c 30-53)
	#echo «Параметр  $i  ${AMI_ARRAY[$i]}   ${AMI_ARRAY[$i+1]}  ${DATE_AMI} »
	DATE_AMI_SEC=`date --date="$DATE_AMI" +"%s"`
	DATE_DIFF_SEC=$((${DATE_START}-${DATE_AMI_SEC}))
	if [ $DATE_DIFF_SEC -gt $SECOUNDS_IN_7DAYS ];	then
		echo « more than 7 days - $DATE_DIFF_SEC seconds.  DELETING  $i  ${AMI_ARRAY[$i]}   ${AMI_ARRAY[$i+1]} ... »
		aws ec2 deregister-image --image-id ${AMI_ARRAY[$i]}
		aws ec2 delete-snapshot --snapshot-id ${AMI_ARRAY[$i+1]}
	else
		if [ $DATE_AMI_SEC -ge $DATE_START ]; 	then
			# new green
			echo -e « new ${GREEN} green ${AMI_ARRAY[$i]} dated $DATE_AMI ${NORMAL} »
		else
			echo -e « old  ${YELLOW} yellow ${AMI_ARRAY[$i]} dated $DATE_AMI ${NORMAL} »
		fi		
	fi
done




