## Linux File System Hierarchy 
# Q -> What is Linux File System : 

Think of the Linux file system as the way Linux organizes, stores, and finds files on your computer. It’s both a structure (how folders are arranged) and a set of rules for managing files.

OS store and manage data on disk or partitions using a structure called filessytem.
Filesystem includes files , directories and it's related permissions.
it stores data in hierarchy of directories and files.

# Types of File system : (used mainly on linux machine)
1. ext3/ext2 
        
        Older versions of ext4

        ext3 adds journaling, ext2 does not

        Rarely used today

2. ext4 

        Most common Linux file system

        Fast, stable, reliable

        Supports large files and disks

3. XFS 
        Very fast, great for large files
        Common on servers

4. Btrfs (B-tree FS )
        Modern, advanced features

        Snapshots, compression, self-healing

        Used in systems like openSUSE

5. NFS -> Network filesystem -> used widely 
           Common in Linux/Unix systems
    SMB / CIFS

            Windows file sharing

            Also works on Linux

# Q-> How we can check which filesystem our host is using , It depends on our operating system . Here are the common ways to check : 

- On Linux Device : 
    1. Check filesystem of mounted drives 
        ```bash
          df -T
        ```
        This shows Mounted filesystem and their type 
        Example Output : 
        ```bash
          Filesystem     Type  Size  Used Avail Use% Mounted on
          /dev/sda1      ext4   50G   20G   28G  42% /
        ```
    2. Check filesystem of a specific directory like /root, /boot
        ```bash
           stat -f /
           stat -f /boot
        ```
    3. Detailed block device info 
        ```bash 
            lsblk -f
        ```
# Quick Comparision Between XFS vs EXT4 
    - XFS -> optimized for large files and volumes , offering superior performance and scalability .
    - EXT4 -> performs well across various file sizes but less efficient with extremely large files.

for High-throughput and extensive parallel processing capabilities , XFS is typically more effective than EXT4


# Filesystem Hierarchy 

1. / (root) Directory -> The linux Filesystem starts at the root directory , denoted by a single slash (/), from which all other files and directories branch out.

2. /bit Directory -> Contains essential user binaries (executables), such as common commands like ls , cp, etc.

3. /etc Directory -> Holds system configuration files.
    Ex. User, Network , Service , System Apps
4. /home Directory -> Contains the personals directories of all users 

5. /root -> The Home directory for the root user (administrator).
6. /var -> Where variable data such as logs and databases are stored.
7. /tmp -> Temporary files created by system and users.
8. /boot -> Holds files needed for system boot-up, including the linux kernel , an initial RAM disk image , bootloaders configuration (like GRUB )
9. /dev -> This directory contains devices files which represent and provide access to hardware devices such as hard drives , sound devices etc.

10. /lib, /lib64 -> These directories contain essential shared libraries and kernel modules that are needed to boot the system and run the command in the root filesystem . The /lib64 directory exists on system that support 64-bit application 
11. /media -> This is the mount point for removable media such as USB drives , CD-ROMs, etc .when these devices are mounted , typically, directories corresponding to their mount points are created within /media.

12. /mnt -> similar to /media , this is a traditional mount point where system administrators can mount temporary filesystem while using or configuration them .

13. /opt -> Intended for the installation of add-on application software package.Large softeare packages that are not part of the default installation can be placed here to avoid cluttering the system directories.

14. /proc -> A virtual and dynamic directory as it only exists in memory. It does not use disk space . It conatains information about system resources , hardware , and running processes . It's a pseudo-filesystem that provide an interface to kernal data structure .

15. /run -> A temporary filesystem that stores transient state files, like process IDs or lock files , since it is cleared and recreated at every boot 

16. /sbin -> Contain binary (executable) files that are mostly needed by the system administrator . These include system management commands like fdisk , shutdown , ip , etc 

17. /sys -> similar to /proc , this is another virtual filesystem that provides an interface to the kernel . It contains information and settings about the system's devices, drivers, and some kernel features.

18. /usr -> considered the secondary hierarchy because it contains all user application and a variety of other things for day-to-day operations, including libraries, documentation , and much more . subdirectories include /use/bin, /usr/sbin, /usr/local and /usr/share among others.


---

### Part 2: Scenario-Based Practice

**Important:** Focus on understanding the **troubleshooting flow**, not memorizing commands. Use the hints!

---

#### SOLVED EXAMPLE: Understanding How to Approach Scenarios

**Example Scenario: Check if a service is running**

```
Question: How do you check if the 'nginx' service is running?
```

**My Solution (Step by step):**

**Step 1:** Check service status
```bash
systemctl status nginx
```
**Why this command?** It shows if the service is active, failed, or stopped

**Step 2:** If service is not found, list all services
```bash
systemctl list-units --type=service
```
**Why this command?** To see what services exist on the system

**Step 3:** Check if service is enabled on boot
```bash
systemctl is-enabled nginx
```
**Why this command?** To know if it will start automatically after reboot

**What I learned:** Always check status first, then investigate based on what you see.

**Scenario 1: Service Not Starting** 

```
A web application service called 'myapp' failed to start after a server reboot.
What commands would you run to diagnose the issue?
Write at least 4 commands in order.
```

**Hint:**
- First check: Is the service running or failed?
- Then check: What do the logs say?
- Finally check: Is it enabled to start on boot?

**Commands to explore:** `systemctl status myapp`, `systemctl is-enabled myapp`, `journalctl -u myapp -n 50`

** solution : 
**Step 1:** systemctl status myapp
Why: Check if the service is failed, inactive, or crashing and view the immediate error message.

**Step 2:** journalctl -u myapp -xe
Why: View detailed logs from systemd to identify startup errors or dependency failures.

**Step 3:** systemctl list-dependencies myapp
Why: Verify if any required services failed to start after reboot.

**Step 4:** systemctl is-enabled myapp
Why: Confirm whether the service is enabled to start automatically on boot.

**Scenario 2: High CPU Usage** 
```
Your manager reports that the application server is slow.
You SSH into the server. What commands would you run to identify
which process is using high CPU?
```

**Hint:**
- Use a command that shows **live** CPU usage
- Look for processes sorted by CPU percentage
- Note the PID (Process ID) of the top process

** solution : 
**Step 1:** top
Why: Get a real-time view of CPU usage and quickly see which process is consuming the most CPU.

**Step 2:** top (press P)
Why: Sort processes by CPU usage inside top to bring the highest CPU consumer to the top

**Step 3:** ps aux --sort=-%cpu | head
Why: Get a snapshot list of the top CPU-consuming processes in descending order.

**Step 4:** ps -o pid,ppid,pcpu,pmem,etime,comm -p <PID>
Why: Inspect the specific high-CPU process in detail (CPU %, memory, runtime, command).

**Scenario 3: Finding Service Logs** 
```
A developer asks: "Where are the logs for the 'docker' service?"
The service is managed by systemd.
What commands would you use?
```

**Hint:**
- systemd services → logs are in journald
- Command pattern: `journalctl -u <service-name>`
- Use -n flag to limit number of lines
- Use -f flag to follow logs in real-time (like tail -f)

** solution :

**Step 1:** systemctl status docker
Why: Confirm the service state and see the recent log lines and service details.

**Step 2:** journalctl -u docker
Why: View all logs collected by systemd’s journal for the docker service.

**Step 3:** journalctl -u docker -f
Why: Follow the logs in real time to monitor live activity or errors.

**Step 4:**  journalctl -u docker --since "1 hour ago"
Why: Filter logs for a specific time window to troubleshoot recent issues

**Scenario 4: File Permissions Issue** 
```
A script at /home/user/backup.sh is not executing.
When you run it: ./backup.sh
You get: "Permission denied"

What commands would you use to fix this?
```

**Hint:**
- First: Check what permissions the file has
- Understand: Files need 'x' (execute) permission to run
- Fix: Add execute permission with chmod

**Step-by-step solution structure:**
```
Step 1: Check current permissions
Command: ls -l /home/user/backup.sh
Look for: -rw-r--r-- (notice no 'x' = not executable)

Step 2: Add execute permission
Command: chmod +x /home/user/backup.sh

Step 3: Verify it worked
Command: ls -l /home/user/backup.sh
Look for: -rwxr-xr-x (notice 'x' = executable)

Step 4: Try running it
Command: ./backup.sh
```
