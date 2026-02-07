# Goal -> Practice Real linux admin workflow using core command 
# Focus: Processes, systemd services, logs, filesystem, networking
# Mindset: “What would I actually run on a production system?”

## Process checks (CPU, memory, state)

- ps aux | head -n 10 -> Quick snapshot of running processes

    ![alt text](image.png)

    Used to : 
        Identify heavy CPU/memory users
        Check process states (R, S, D, Z)

- top or htop -> Live System monitoring 
    
    ![alt text](image-1.png)

    Key things observed:

            Load average -> 0.08 

            %CPU usage -> 0.0 to 1.3%
 
            Memory usage -> 285M/1.8G

            Which process is consuming resources -> 

- pstree -p | head ->  Visualize process hierarchy 

    ![alt text](image-2.png)

    Helps us to understand parent child relationship 

## Service checks (systemd fundamentals)

- systemctl list-units --type=service --all -> This will list all the servocees running in that particular server 

    ![alt text](image-3.png)

- systemctl status docker.service -> It will tell you the status of the particular service that is active ot    inactive  
        ![alt text](image-4.png)
        ![alt text](image-5.png)

        confirms -> service health , PID , Startup behaviour 
- systemctl is-enabled docker.service -> Check if service starts at boot

## File system & disk checks
 
 - df -h -> check disk space usage
   ![alt text](image-6.png)
 
  Disk Full = service failure 

-  du -shx -> It shows how much disk space files/directories use.
    
    Flags:

            -s → summary

                 Don’t list every file inside, just the total per argument

            -h → human-readable

                Shows sizes like K, M, G instead of raw bytes

            -x → stay on one filesystem

                Don’t cross into other mounted filesystems (important on servers)

- du -sh /var/log/* | sort -h | tail ->  Shows the size of each directory or file inside /var/log /Find large log files

    ![alt text](image-7.png)

- lsblk -> View block devices and mount points -> Essential for storage and SAN/NFS debugging.
          ![alt text](image-8.png)

- mount | grep nfs -> Check NFS mounts (if any) 
    Important for detecting storage-related hangs (D state).

## Networking quick checks (fundamental)

- ip addr -> Check IP addresses and interfaces -> first step if network services fail.
     ![alt text](image-9.png)
- ping -c 3 8.8.8.8 -> Verify basic network connectivity-> checing if the ggole server is reachable or not 
  ![alt text](image-10.png)

