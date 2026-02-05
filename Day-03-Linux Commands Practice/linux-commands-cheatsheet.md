## Linux Admin  Cheat Sheet 

# Process Management 
1. ps aux -> list all running processes with CPU and memory usage 
2. top -> Real-time Process and system resource motoring 
3. htop -> Enhanced interactive process viewer
4. pstree -p -> Display process hierarchy with PIDs(process ID's)
5. kill PID -> Gracefully terminate a process (SIGTERM)
6. kill -9 PID –> Force kill a process (SIGKILL)
7. pkill name –>  Kill process by name
8. nice -n 10 <cmd> –>  Start a process with lower priority
9. renice -n -5 -p PID -> Change priority of a running process
10. jobs – List background jobs in current shell
11. bg / fg – Resume job in background or foreground


## File System & Storage
12. ls -lh – List files with sizes in human-readable format
13. df -h – Show filesystem disk usage
14. du -shx dir/ – Show disk usage of a directory
15. mount – List mounted filesystems
16. lsblk – Display block devices and mount points
17. find /path -name file – Search files by name
18. chmod 755 file – Change file permissions
19. chown user:group file – Change file ownership
20. stat file – Show detailed file metadata
21. touch file – Create empty file or update timestamp


## Networking & Troubleshooting
22. ping host – Check network connectivity and latency
23. ip addr – Show IP addresses and interfaces
24. ip route – Display routing table
25. ss -tuln – List listening TCP/UDP ports
26. curl URL – Test HTTP/HTTPS connectivity
27. dig domain – DNS lookup and troubleshooting
