#
DATAFILE=data.csv
USERFILE=users.txt
cd /var/update-hosts/
touch $DATAFILE
touch $USERFILE
nmap -oG nmap.log -sP 10.0.0.0/24


cat nmap.log | sed "s/'/\'/;s/Host: //g;s/^//;s/$//;s/\n//g"  | sed "s/'/\'/;s/ .*//g;s/^//;s/$//;s/\n//g" | sed "s/'/\'/;s/#.*/1\.1\.1\.1/g;s/^//;s/$//;s/\n//g" > $DATAFILE


## Working MySQL ##
# mysql --user=cactimonitor -p********** cacti -B -e "SELECT hostname,description FROM cacti.host;" | sed "s/'/\'/;s/[,() ]/-/g;s/^//;s/$//;s/\n//g" | sed "s/'/\'/;s/\t/,/g;s/^//;s/$//;s/\n//g" | awk '{print tolower($0)}' > $DATAFILE

#

ls /home/ | grep - > $USERFILE
#
INPUT=$DATAFILE
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
#while read IP NAME #For Cacti

while read IP
do
	echo "IP : $IP"
#	echo "Cacti NAME : $NAME"
	SYSNAME=$(/usr/bin/snmpwalk -OUEvqt -t 1 -r 0 -c ***************** -v2c $IP SNMPv2-MIB::sysName.0 | awk '{print tolower($0)}' | sed "s/'/\'/;s/\..*//g;s/^//;s/$//;s/\n//g" )
	echo "snmpwalk sysName : $SYSNAME"
	touch "/var/update-hosts/touch-files/$SYSNAME"

	echo "$IP,$SYSNAME,$(date)" >> hosts.csv	


#	if grep -e "$SYSNAME" hosts.txt > /dev/null; then
	if grep -e "$SYSNAME" /etc/hosts > /dev/null; then

		echo "Found in hosts"
		sed -i '/'"$SYSNAME"'/ s/.*/'"$IP $SYSNAME #Updated $(date)"'/' /etc/hosts

	else
		echo "$IP $SYSNAME # New $(date)" >> /etc/hosts
		echo "NOT Found in hosts"
	fi


done < $INPUT




IFS=$OLDIFS


INPUT=$USERFILE
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read NAME
do
	echo "NAME : $NAME"
	cp /var/update-hosts/touch-files/* /home/$NAME
	
done < $INPUT
IFS=$OLDIFS
