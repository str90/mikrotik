#!/bin/bash

CSV_URL="http://reestr.rublacklist.net/api/v2/ips/csv"
SOURCE_FILE=/tmp/rkncsv.csv
MIKROTIK_ADDRESS_LIST="list_roskomnadzor"
MIKROTIK_LIST_FILE=/tmp/mikrotikfile.rsc
MIKROTIK_USER=agat
MIKROTIK_PASSWORD_PATH=/home/str/rkn_mikrotik/agat_pass_mikrotik
MIKROTIK_ADDRESS=192.168.57.1
MIKROTIK_SSH_PORT=24

echo "Removing old list"
sshpass -f $MIKROTIK_PASSWORD_PATH ssh -p $MIKROTIK_SSH_PORT $MIKROTIK_USER@$MIKROTIK_ADDRESS /ip firewall address-list remove [/ip firewall address-list find list="list_roskomnadzor"]

echo "Getting source file"
wget $CSV_URL -O $SOURCE_FILE

echo "Populating mikrotik .rsc file"
for CURRENT_LINE in $(cat $SOURCE_FILE); do
    echo /ip firewall address-list add address="$CURRENT_LINE" list="$MIKROTIK_ADDRESS_LIST" >> $MIKROTIK_LIST_FILE
done

echo "Adding custom addresses"
echo /ip firewall address-list add address="8.8.8.8" list="$MIKROTIK_ADDRESS_LIST" >> $MIKROTIK_LIST_FILE #custom addresses
echo /ip firewall address-list add address="8.8.4.4" list="$MIKROTIK_ADDRESS_LIST" >> $MIKROTIK_LIST_FILE
echo /ip firewall address-list add address="94.23.36.128" list="$MIKROTIK_ADDRESS_LIST" >> $MIKROTIK_LIST_FILE
echo /ip firewall address-list add address="91.121.222.33" list="$MIKROTIK_ADDRESS_LIST" >> $MIKROTIK_LIST_FILE
echo /ip firewall address-list add address="91.121.167.111" list="$MIKROTIK_ADDRESS_LIST" >> $MIKROTIK_LIST_FILE
echo /ip firewall address-list add address="46.105.121.53" list="$MIKROTIK_ADDRESS_LIST" >> $MIKROTIK_LIST_FILE

echo "Sending file to mikrotik"
sshpass -f $MIKROTIK_PASSWORD_PATH sftp -P $MIKROTIK_SSH_PORT $MIKROTIK_USER@$MIKROTIK_ADDRESS <<EOF
put $MIKROTIK_LIST_FILE
EOF

echo "Importing rules on mikrotik"
sshpass -f $MIKROTIK_PASSWORD_PATH ssh $MIKROTIK_USER@$MIKROTIK_ADDRESS -p $MIKROTIK_SSH_PORT /import mikrotikfile.rsc

echo "Removing temporary files"
rm $SOURCE_FILE
rm $MIKROTIK_LIST_FILE
sshpass -f $MIKROTIK_PASSWORD_PATH ssh $MIKROTIK_USER@$MIKROTIK_ADDRESS -p $MIKROTIK_SSH_PORT /file remove mikrotikfile.rsc

echo "Done !"

exit 0

