# Task 1: Log Rotation Script

```bash 

#!/bin/bash

set -euo pipefail

if [ $# -eq 0 ]
then
    echo "Usage: ./log_rotate.sh <log_directory>"
    exit 1
fi

log_dir="$1"

if [ ! -d "$log_dir" ]
then
    echo "Error: Directory does not exist"
    exit 1
fi

echo "Processing logs in: $log_dir"

compressed_count=$(find "$log_dir" -name "*.log" -mtime +7 | wc -l)

find "$log_dir" -name "*.log" -mtime +7 -exec gzip {} \;

echo "Compressed files: $compressed_count"

deleted_count=$(find "$log_dir" -name "*.gz" -mtime +30 | wc -l)

find "$log_dir" -name "*.gz" -mtime +30 -delete

echo "Deleted compressed files: $deleted_count"

echo "Log rotation completed successfully"

```
- This script automates log rotation by compressing old log files and removing stale compressed logs. It also validates input, handles errors safely using strict mode, and reports how many files were processed
