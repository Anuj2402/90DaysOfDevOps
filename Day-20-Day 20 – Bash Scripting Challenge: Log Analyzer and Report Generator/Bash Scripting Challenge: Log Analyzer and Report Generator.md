# Day 20 – Bash Scripting Challenge: Log Analyzer and Report Generator

# Task 1: Input and Validation

Script: 
```bash
#!/bin/bash

set -euo pipefail # -e means stop the execution then and there, -u bhai ne undefined value bhja hain , -o koi pipe command fail hua hain 

# Check if argument is provided
# Agar Argument nahi provide kiya ho tho error through karna hain , with suggestion ki right approach kya hona chaiya

if [ $# -eq 0 ] 
then
    echo "Usage: ./log_analyzer.sh <log_file>"
    exit 1
fi

log_file="$1"

# Check if file exists
if [ ! -f "$log_file" ]
then
    echo "Error: File does not exist: $log_file"
    exit 1
fi

echo "Log file validated successfully: $log_file"

```
