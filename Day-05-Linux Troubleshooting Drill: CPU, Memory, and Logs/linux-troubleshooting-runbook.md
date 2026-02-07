

```markdown
# Linux Troubleshooting Runbook

**Date:** 2026-02-07  
**Target Service:** `process_api` (PID 1)  
**Purpose:** Health check and baseline diagnostics

---

## Target Service / Process

**Service:** process_api (main container process)  
**Command:** `/process_api --addr 0.0.0.0:2024 --max-ws-buffer-size 32768 --cpu-shares 1024 --oom-polling-period-ms 100 --memory-limit-bytes 4294967296 --block-local-connections`  
**PID:** 1

---

## Environment Basics

### System Information
```bash
$ uname -a
Linux runsc 4.4.0 #1 SMP Sun Jan 10 15:06:54 PST 2016 x86_64 x86_64 x86_64 GNU/Linux
```
**Observation:** Running on 64-bit Linux kernel 4.4.0 (gVisor sandbox environment)

### OS Release
```bash
$ cat /etc/os-release
Ubuntu 24.04.3 LTS (Noble Numbat)
```
**Observation:** Ubuntu 24.04.3 LTS, up-to-date Noble release

---

## Filesystem Sanity

### Basic File Operations
```bash
$ mkdir -p /tmp/runbook-demo && cp /etc/hosts /tmp/runbook-demo/hosts-copy && ls -l /tmp/runbook-demo
total 1
-rwxr-xr-x 1 root root 98 Feb  7 11:21 hosts-copy
```
**Observation:** Filesystem read/write operations working normally, proper permissions set

### Write Test
```bash
$ echo "test" > /tmp/runbook-demo/test.txt && cat /tmp/runbook-demo/test.txt
test
```
**Observation:** File creation and content verification successful

---

## Snapshot: CPU & Memory

### Process Resource Usage
```bash
$ ps -o pid,pcpu,pmem,comm -p 1
  PID %CPU %MEM COMMAND
    1  1.7  0.2 process_api
```
**Observation:** CPU usage at 1.7% (very low), memory at 0.2% - process running efficiently

### System Memory
```bash
$ free -h
               total        used        free      shared  buff/cache   available
Mem:           9.0Gi        13Mi       9.0Gi          0B       8.2Mi       9.0Gi
Swap:             0B          0B          0B
```
**Observation:** 9GB total memory, only 13MB used (99.8% free), no swap configured - excellent memory health

---

## Snapshot: Disk & IO

### Disk Usage
```bash
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
none            9.9G  2.1M  9.9G   1% /
none            315G     0  315G   0% /dev
none            1.0P     0  1.0P   0% /mnt/user-data/outputs
```
**Observation:** Root filesystem at 1% usage (2.1M/9.9G), plenty of space available on all mounts

### Log Directory Size
```bash
$ du -sh /var/log
967K    /var/log
```
**Observation:** Log directory using less than 1MB - no log bloat detected

---

## Snapshot: Network

### Process Details
```bash
$ ps -eo pid,comm,args | grep process_api | head -5
1 process_api /process_api --addr 0.0.0.0:2024 --max-ws-buffer-size 32768...
```
**Observation:** Service configured to listen on 0.0.0.0:2024 with 32KB websocket buffer

### Endpoint Test
```bash
$ curl -I http://localhost:2024
curl: (56) Recv failure: Connection reset by peer
```
**Observation:** Service resets connections on HTTP requests - expected behavior for specialized API, not an HTTP endpoint

---

## Logs Reviewed

### Package Management Activity
```bash
$ tail -n 50 /var/log/dpkg.log | head -20
2025-11-21 01:59:15 status installed glib-networking:amd64 2.80.0-1build1
2025-11-21 01:59:15 status installed libsoup-3.0-0:amd64 3.4.4-5ubuntu0.5
2025-11-21 01:59:15 status installed gstreamer1.0-plugins-good:amd64 1.24.2-1ubuntu1.2
```
**Observation:** Last package activity on Nov 21, system packages installed successfully with no errors

### Kernel Messages
```bash
$ dmesg | tail -30
[    0.000000] Starting gVisor...
[    2.037075] Ready!
```
**Observation:** Clean boot sequence, no kernel errors or warnings, system initialization completed successfully

---

## Quick Findings

✅ **System Health:** Excellent  
✅ **Resource Usage:** Very low (1.7% CPU, 0.2% memory)  
✅ **Disk Space:** 99% available  
✅ **Filesystem:** Operating normally  
✅ **Logs:** Clean, no errors detected  
⚠️ **Network:** Service endpoint behavior not typical HTTP (connection reset - may be intentional for this API type)

**Overall Status:** System is healthy and stable. The process_api service is running with minimal resource consumption and no errors detected in logs or system state.

---

## If This Worsens (Next Steps)

If resource usage spikes, service becomes unresponsive, or errors appear:

1. **Enable verbose logging and capture strace**
   - Run `strace -p 1 -f -e trace=network,file -o /tmp/process_api.strace` to capture system calls
   - Check if the service has a debug/verbose mode flag and restart with increased logging
   - Monitor `/var/log/syslog` or create dedicated service log if not already present

2. **Collect detailed resource metrics over time**
   - Set up continuous monitoring: `while true; do ps -p 1 -o pid,pcpu,pmem,vsz,rss >> /tmp/process_api_metrics.log; sleep 5; done &`
   - Use `iotop` or `pidstat` to identify if disk I/O becomes a bottleneck
   - Review memory maps with `pmap 1` to detect memory leaks or unusual allocations

3. **Implement graceful restart strategy with state preservation**
   - Document current service configuration and startup parameters
   - Test service restart procedure: capture pre-restart state, restart, verify post-restart health
   - If restart required in production, ensure connection draining or queue persistence if applicable
   - Consider implementing health check endpoint to automate failure detection

**Escalation Threshold:** CPU >80% sustained for 5+ minutes, memory >70%, or repeated connection failures
```
