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


# Task 2: Server Backup Script

```bash 
#!/bin/bash

set -euo pipefail

# Check arguments
if [ $# -ne 2 ]
then
    echo "Usage: ./backup.sh <source_directory> <backup_destination>"
    exit 1
fi

source_dir="$1"
backup_dir="$2"

# Check if source directory exists
if [ ! -d "$source_dir" ]
then
    echo "Error: Source directory does not exist"
    exit 1
fi

# Create backup destination if missing
mkdir -p "$backup_dir"

# Create timestamp
timestamp=$(date +%F-%H-%M-%S)

# Archive name
archive_name="backup-$timestamp.tar.gz"

# Full archive path
archive_path="$backup_dir/$archive_name"

echo "Creating backup..."

# Create tar.gz archive
tar -czf "$archive_path" "$source_dir"

# Verify archive created successfully
if [ -f "$archive_path" ]
then
    echo "Backup created successfully"
else
    echo "Backup failed"
    exit 1
fi

# Print archive details
echo "Archive Name: $archive_name"

archive_size=$(du -h "$archive_path" | awk '{print $1}')

echo "Archive Size: $archive_size"

# Delete backups older than 14 days
find "$backup_dir" -name "*.tar.gz" -mtime +14 -delete

echo "Old backups deleted"

echo "Backup process completed successfully"

```


