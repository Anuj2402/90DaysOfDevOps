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

# Task 2: Error Count
- For Task 2, after validating the log file, count lines containing either ERROR or Failed

```bash 
#!/bin/bash

set -euo pipefail

# Validation
if [ $# -eq 0 ]
then
    echo "Usage: ./log_analyzer.sh <log_file>"
    exit 1
fi

log_file="$1"

if [ ! -f "$log_file" ]
then
    echo "Error: File does not exist: $log_file"
    exit 1
fi

# Count ERROR or Failed
error_count=$(grep -E "ERROR|Failed" "$log_file" | wc -l)

echo "Total Errors: $error_count"

```
Explanation: 

- grep -> Searches text.

- -E -> Enables extended regular expressions , "ERROR|Failed"

Means:

    ERROR OR Failed

Exmaple log in the log File: 
```
INFO Application started
ERROR Database connection failed
INFO User login
Failed to connect to API
ERROR Timeout occurred
```

grep output: 

```
ERROR Database connection failed
Failed to connect to API
ERROR Timeout occurred
```
WC -l -> will count the number of log lines which is 3 stored in error_count=3

Final Output: 
    
    Total error count : 3 


