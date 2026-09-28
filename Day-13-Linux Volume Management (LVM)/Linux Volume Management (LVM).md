# Q-> What is Linux Volume Management 
- Linux Volume Management refers to how storage (hard drives, SSDs, partitions) is organized, allocated, and managed in a Linux system. It allows you to control disk space more flexibly than traditional fixed partitions.
- The most common system used in Linux for this is Logical Volume Manager (LVM).

## Basic Storage Without Volume Management
Traditionally:
 - A disk (e.g., /dev/sda)

 - Is divided into fixed partitions (/dev/sda1, /dev/sda2)
 - Each partition has a filesystem (ext4, xfs, etc.)
 - Sizes are set at creation and are hard to change later

Problem : 
  - If one partition fills up, you can’t easily resize it.

  - Adding new disks requires manual reconfiguration.

## With Linux Volume Management (LVM)
LVM adds a layer of abstraction between physical disks and filesystems.

Instead of:

- Disk → Partition → Filesystem

You get:

- Disk → Physical Volume → Volume Group → Logical Volume → Filesystem

Key LVM Components
1️⃣ Physical Volume (PV)

- A physical disk or partition prepared for LVM

- Example: **/dev/sdb**

2️⃣ Volume Group (VG)

- A pool of storage created from one or more PVs

 - Think of it as a big storage container

3️⃣ Logical Volume (LV)

- Virtual partitions created from the VG

- These are what you actually format and mount

- Can be resized easily

# Before WE Start

No spare disk? Create a virtual one: 
NOTE : If /tem has less space than what you required create eith /export path 
```bash 
dd if=/dev/zero of=/tmp/disk1.img bs=1M count=1024

losetup -fP /tmp/disk1.img

losetup -a   # Note the device name (e.g., /dev/loop0)
```
After this when you lsblk you should see the **/dev/loop0** as a virtually created device 

![alt text](image.png)

## TASK 1 -> Create Physical Volume (PV)
```bash 
pvcreate /dev/loop0 # this is for creating the physical volume 
```
Verify :
```bash 
pvs
pvdisplay /dev/loop0 # this will list the details info about the created PV
```
Example Output :
![alt text](image-1.png)

What Happened : 

- Created a Physical Volume on **/dev/loop0**

- Verified using pvs and pvdisplay

- Initially not part of any Volume Group

## Task 2 – Create Volume Group (VG)
```bash 
vgcreate devops-vg /dev/loop0
```
verify :
```bash 
vgs
vgdisplay devops-vg
```
Exmaple Output : 
![alt text](image-2.png)

What Happened

- Created VG named devops-vg

- Default PE size = 4MB

- Total usable size = 1020MB (after metadata reservation)

## Task 3 – Create Logical Volume (LV)
```bash 
lvcreate -L 500M -n app-data devops-vg
```
Verify : 
```bash 
lvs
lvdisplay /dev/devops-vg/app-data
```
Example Output : 
![alt text](image-3.png)

What Happened

- Created 500MB Logical Volume

- 125 extents allocated (125 × 4MB = 500MB)

- Verified LV is available and active

## Task 4 – Create Filesystem
```bash 
mkfs.ext4 /dev/devops-vg/app-data
```
verify :
```bash 
blkid /dev/devops-vg/app-data
```
Example output : 
![alt text](image-4.png)

What Happened

- Formatted LV with ext4

- Block size automatically selected as 1K (because filesystem is small)

- Filesystem successfully created

## Task 5 – Mount Logical Volume
```bash 
mkdir /mnt/app-data # this will create the  mount directory first 
mount /dev/devops-vg/app-data /mnt/app-data. # it mount the lv to the mount point 
```
verify : 
```bash 
df -h #it will list the mount directory 
```
Example output:
![alt text](image-5.png) 

What Happened

- Mounted LV to /mnt/app-data

- Usable size shows ~474MB (metadata + reserved blocks used)


## Task 6 – Test File Creation
```bash 
echo "LVM is working" > /mnt/app-data/hello.txt
touch /mnt/app-data/testfile
```
verify : 
```bash 
ls -l /mnt/app-data
```
Example output: 
![alt text](image-6.png)
What Happened

- Verified write operations

- Filesystem functioning correctly

## Task 7 – Extend Logical Volume (Online)
```bash 
lvextend -L 800M /dev/devops-vg/app-data
```
verify : 
```bash 
lvs
vgs
```
Example Output: 
![alt text](image-7.png)
What Happened

- Extended LV from 500MB → 800MB

- Performed while filesystem was mounted (no downtime)

- VG free space reduced accordingly

## Task 8 – Resize Filesystem Online

```bash 
resize2fs /dev/devops-vg/app-data
```
verify : 
```bash 
df -h /mnt/app-data
```
Example output : 
![alt text](image-8.png)

What Happened

- Resized ext4 filesystem online

- Filesystem grew to match 800MB LV

- No unmount required

Final Architecture

```bash 
File (1GB)
   ↓
/dev/loop0
   ↓
Physical Volume
   ↓
Volume Group (devops-vg)
   ↓
Logical Volume (app-data - 800MB)
   ↓
ext4 Filesystem
   ↓
Mounted at /mnt/app-data

```

### Q-> Can you explain process of Creating a and Mounting an filesystem 
Process of creating and mounting a new filesystem in Linux
```
Create disk/partition
       ↓
Create filesystem
       ↓
Create mount point
       ↓
Mount filesystem
       ↓
Verify
       ↓
(Optional) Configure /etc/fstab for automatic mounting

```
1. Identify the disk/partition
```bash 
lsblk 
```
Example: 
```
/dev/sdb
└─/dev/sdb1 -> This will create after partition 

```
2. Create a partition
If the disk is new/unpartitioned, use `fdisk` or `parted`:
```bash 
 sudo fdisk /dev/sdb
 ```
 Create a partition such as `/dev/sdb1`.
 Then check:
 ```
 lsblk 
 ```
 3. Create the filesystem
 For an `ext4` filesystem:
 ```bash 
 sudo mkfs.ext4 /dev/sdb1
```
This **formats the partition**, so make sure it doesn't contain data you need.

4. Create a mount point
A mount point is the directory where the filesystem will appear:
```bash 
sudo mkdir -p /data
```
5. Mount the filesystem
```bash 
sudo mount /dev/sdb1 /data
```
Now `/dev/sdb1` is accessible through `/data.`

6. Verify
```bash 
df -h /data
or:
mount | grep /data  
```
You can also use:
```bash 
lsblk -f
```
7. Configure permanent mounting
A manual mount disappears after reboot. To mount it automatically, add an entry to `/etc/fstab`.
First find the UUID:
```bash 
sudo blkid /dev/sdb1
```
Example:
```
UUID="abc123..." TYPE="ext4"

```
Then add:
```
UUID=abc123...  /data  ext4  defaults  0  2
```
Test the configuration before rebooting:
```bash 
sudo mount -a
```

If there are no errors, the filesystem should automatically mount at `/data `after boot.

Interview-ready answer
“To create and mount a new filesystem in Linux, I follow a few steps.

First, I identify the available disk using lsblk. If the disk is new and needs partitioning, I create a partition using tools like fdisk or parted.

Next, I create a filesystem on the partition using mkfs, for example mkfs.ext4 /dev/sdb1.

Then I create a mount-point directory, such as /data, using mkdir.

After that, I mount the filesystem using the mount command:

mount /dev/sdb1 /data

I verify that it was mounted successfully using df -h, mount, or lsblk -f.

Finally, if I want the filesystem to be mounted automatically after a reboot, I get its UUID using blkid and add an entry to /etc/fstab. I then test it with mount -a to make sure there are no configuration errors.”

```bash 
lsblk
sudo fdisk /dev/sdb
sudo mkfs.ext4 /dev/sdb1
sudo mkdir /data
sudo mount /dev/sdb1 /data
df -h /data
sudo blkid /dev/sdb1
sudo vi /etc/fstab
sudo mount -a
```
