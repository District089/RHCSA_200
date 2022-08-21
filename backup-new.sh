#This script backups files + directories from watzmann and logs the output 
#You can create an entry in crontab for automatic execution at a specific time (e.g. /etc/cron.weekly or "crontab -e")
#The current entry you can find in root@watzmann.abg.fsc.net via "crontab -e" (0 12 * * 6 /home1/pe/watzmann/p.cron.watzmann.sh > /home1/pe/watzmann/p.cron.result 2>&1)

#Created Date: 08.08.2022

#!/bin/bash 
set-x

#Set variables
INFODIR=/home1/pe/watzmann/watzmann.info #Here you can find the files from /etc/ and /var/
BACKLOG=backup.log #Logfile for the backup processes
WEEKLYDATE=$(($(date +%W) % 4))
DAIYLYDATE=$(date  +%a)
DESTINATIONPATHWEEK=/home2/watzman-save/backups/weekly-$WEEKLYDATE
DESTINATIONPATHDAILY=/home2/watzmann-save/backups/daily-$DAILYDATE
SOURCENAME=watzmann-`date +%Y%m%d`
BACKUPS_OLD=`ls -l $BACKUPPATH | wc -l`
BACKUPPATH=/home2/watzmann-save/backups/
DAYS=4

#Clean and remake "$INFODIR"
rm -rf $INFODIR && mkdir $INFODIR && date > $INFODIR/date && uname -a > $INFODIR/uname-a

#Creates a log file for the backup processes
{ echo " " ; echo "=== `date` on `hostname` ===" ; echo " " ; echo "Timestamp before work is done `date +"%D %T"`" ; } >> $INFODIR/$BACKLOG

#Creates backups from /etc/ + /var/ and copies the output in $BACKLOG

#Statt dem Block darüber (In der list.lst finden sich die Pfade)
rsync -avr --files-from=/$INFODIR/list.lst / /$INFODIR >> $INFODIR/$BACKLOG

validate=`echo $?`

if [ $validate -gt 1 ]
then
echo "Finished copying files" >> $INFODIR/$BACKLOG
else
echo "Copying files not succeed"
fi

chown -R pe $INFODIR

#Vollbackup (weekly)
#rsync -av /home1/pe/lambda /home1/pe/watzmann /home1/pe/htdocs /home1/pe/bs2-config /home1/pe/bs2-results /home1/pe/Benchmarks /home1/pe/PHB /home1/pe/Performance-Team /home1/pe/Know-How /home1/pe/RZ_MCH-E /home1/pe/Referenztabellen --exclude {'/home1/pe/Performance-Team/Galerie/*','/home1/pe/Know-How/Manuale, Anleitungen, Datenblaetter/*','/home1/pe/Know-How/Kurse/*'} root@hochgern.abg.fsc.net/home2/watzman-save/backups/weekly-$TARFILE-$(($(date +%W) % 4))
rsync -av --files-from/$INFODIR/include.lst --exclude-from={'exclude.lst'} root@hochgern.abg.fsc.net:$DESTINATIONPATHWEEK-$SOURCENAME >> $INFODIR/$BACKLOG

#Compress old full-backup
for i in $BACKUPPATH;
do if [ $BACKUPS_OLD -ge 1 ];
then
    tar -cpzvf watzmann-`date -d "7 days ago" +%Y%m%d`.tar.gz $i;
fi
done

#Delete old Backups
if [ $BACKUPS_OLD -gt 4 ];
then
    find $BACKUPPATH -name "watzmann-*" -daystart -mtime +31 -delete
fi

#Inkrementell (daily)
rsync -av --files-from/$INFODIR/include.lst --exclude-from={'exclude.lst'} --link-dest=$DESTINATIONPATHWEEK-$SOURCENAME root@192.168.178.85:$DESTINATIONPATHDAILY-$SOURCENAME




#Making a tar file from watzmann 
tar -cpzvf $TARFILE /home1/pe/lambda /home1/pe/watzmann /home1/pe/htdocs /home1/pe/bs2-config /home1/pe/bs2-results /home1/pe/Benchmarks /home1/pe/PHB /home1/pe/Performance-Team /home1/pe/Know-How /home1/pe/RZ_MCH-E /home1/pe/Referenztabellen --exclude '/home1/pe/Performance-Team/Galerie/*' --exclude '/home1/pe/Know-How/Manuale, Anleitungen, Datenblaetter/*' --exclude '/home1/pe/Know-How/Kurse/*' >> $INFODIR/$BACKLOG 2>&1 && echo "Finished copying files" >> $INFODIR/$BACKLOG && echo "Timestamp after work is done `date +"%D %T"`" >> $INFODIR/$BACKLOG

#Send the backup to the remote host
scp -p $TARFILE root@hochgern.abg.fsc.net:/home2/watzmann-save 
