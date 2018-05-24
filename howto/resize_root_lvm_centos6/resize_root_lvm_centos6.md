check size root in byte:
---------------------------------------------------------------
fdisk -l /dev/mapper/vg_servername-root
Dysk /dev/mapper/vg_servername-root: 53.4 GB, bajtów: 53435432960

-----------------------------------------------------------------

create snapshot and create_newroot
-----------------------------------------------------------------
lvcreate -s /dev/mapper/vg_servername-root -L 5G -n rootmigawka
lvcreate -L 53435432960b -n newroot vg_servername
partclone.ext4 -b -N -s  /dev/mapper/vg_servername-rootmigawka -o  /dev/mapper/vg_servername-newroot

---------------------------------------------------------------

edit fstab in old root:
---------------------------------------------------------------
#/dev/mapper/vg_servername-root /                       ext4    defaults        1 1
/dev/mapper/vg_servername-newroot /                       ext4    defaults        1 1

-----------------------------

edit fstab in new root:
---------------------------------------------------------------
#/dev/mapper/vg_servername-root /                       ext4    defaults        1 1
/dev/mapper/vg_servername-newroot /                       ext4    defaults        1 1

---------------------------------------------------------------
edid grub.conf change root to newroot:
---------------------------------------------------------------
kernel /vmlinuz-2.6.32-696.20.1.el6.x86_64 ro root=/dev/mapper/vg_servername-newroot rd_LVM_LV=vg_servername/newroot rd_NO_LUKS rd_LVM_LV=vg_servername/swap rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=auto selinux=0 kernel.panic=30 LANG=pl_PL.UTF-8  KEYBOARDTYPE=pc KEYTABLE=pl2 rd_NO_DM     

---------------------------------------------------------------
REBOOT
---------------------------------------------------------------

change orginall root size:
---------------------------------------------------------------
lvremove -f /dev/vg_servername/rootmigawka
lvresize -r -L -30G /dev/mapper/vg_servername-root

---------------------------------------------------------------

edit fstab in old root:
---------------------------------------------------------------
/dev/mapper/vg_servername-root /                       ext4    defaults        1 1
#/dev/mapper/vg_servername-newroot /                       ext4    defaults        1 1

---------------------------------------------------------------

edit fstab in new root:
---------------------------------------------------------------
/dev/mapper/vg_servername-root /                       ext4    defaults        1 1
#/dev/mapper/vg_servername-newroot /                       ext4    defaults        1 1

---------------------------------------------------------------

edit grub newroot to root:
---------------------------------------------------------------
kernel /vmlinuz-2.6.32-696.20.1.el6.x86_64 ro root=/dev/mapper/vg_servername-root rd_LVM_LV=vg_servername/root rd_NO_LUKS rd_LVM_LV=vg_servername/swap rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=auto selinux=0 kernel.panic=30 LANG=pl_PL.UTF-8  KEYBOARDTYPE=pc KEYTABLE=pl2 rd_NO_DM

---------------------------------------------------------------
REBOOT
---------------------------------------------------------------
lvremove /dev/mapper/vg_servername-newroot





