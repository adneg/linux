#!/bin/bash
export PATH=/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

#ZMIENNE:
stat=0
VG="vg_kvmback"
LVP="win2k16"
LVK="_snap"
GUEST="win2k8-2"
DAY=`date +%u`
adresy_email=kamil@topsa.com.pl,mtasz@topsa.com.pl
firma="cbi-win TOPSA"


lvmsnap()
{
echo "lvmsnap"
lvcreate -s /dev/$VG/$LVP -L 10G -n $LVP$LVK &&\


virsh dumpxml $GUEST > /Kopia/cbi_win_kopia/$DAY/$GUEST".xml"


partprobe /dev/mapper/$VG-$LVP$LVK  &&\
dd if=/dev/mapper/$VG-$LVP$LVK of=/Kopia/cbi_win_kopia/$DAY/mbr.dd bs=512 count=1
sfdisk -d /dev/mapper/$VG-$LVP$LVK > /Kopia/cbi_win_kopia/$DAY/mbr.sfdisk &&\
partclone.ntfs -c -s /dev/mapper/$VG-$LVP$LVK"p1" | gzip -c > /Kopia/cbi_win_kopia/$DAY/p1.pcl.gz &&  stat=1 ||\
ERROR 

dmsetup remove /dev/mapper/$VG-$LVP$LVK"p1" 
lvremove -f $VG/$LVP$LVK
}


ERROR(){
echo "error"
echo "[ EE ] Kopia WIN_KVM $firma" | mail -s "[ EE ] Kopia WIN_KVM $firma" $adresy_email 

}

#virsh send-key $GUEST --codeset xt 37 18 21

#virsh  qemu-monitor-command $GUEST mouse_move 500 5000 --hmp
#virsh  qemu-monitor-command $GUEST mouse_move 100 100 --hmp 
#virsh  qemu-monitor-command $GUEST mouse_move 500 5000 --hmp
#sleep 2
#virsh shutdown $GUEST
#sleep 80 

#STAN=`virsh list --all |grep  $GUEST |awk '{ print $3}'`

STAN="wyłączone"
if  [ "$STAN" == "wyłączone" ] 
then
    lvmsnap
else
    ERROR
fi
if [ "$stat" == "1" ]
	then
		/usr/local/bin/borg prune -d 1 -w 1 -m 1 -y 1 /Kopia/BORG/
		/usr/local/bin/borg create --compression none /Kopia/BORG/::obraz-`date +%F`  /Kopia/cbi_win_kopia/$DAY  && rm -f /Kopia/cbi_win_kopia/$DAY/p1.pcl.gz &&\
		echo "[ OK ] Kopia WIN_KVM $firma" | mail -s "[ OK ] Kopia WIN_KVM $firma" $adresy_email || ERROR

	else
	ERROR
fi

#lvcreate -s /dev/$VG/$LVP -L 10G -n $LVP$LVK



