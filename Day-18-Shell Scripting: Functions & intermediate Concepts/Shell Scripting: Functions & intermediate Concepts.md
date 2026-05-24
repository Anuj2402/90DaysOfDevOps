# Task 1: Basic Functions

```bash
#!/bin/bash 


greet(){

    echo "Hello $1!"
}

add(){

    local sum=$(( $1 + $2 ))
    echo "sum is $sum"
}

greet Anuj Yadav
add 10 40 
```
Example output: 
![alt text](image.png)


# Task 2: Functions with Return Values

```bash 
#!/bin/bash

# Function to check disk usage
check_disk() {
    echo "Disk Usage:"
    df -h /
}

# Function to check memory usage
check_memory() {
    echo "Memory Usage:"
    free -h
}

# Main section
echo "System Health Check"
echo "-------------------"

check_disk
echo

check_memory

```
Example output : 
![alt text](image-1.png)




Task 3: Strict Mode — set -euo pipefail

```bash 
#!/bin/bash

set -euo pipefail

echo "Starting script..."

# -----------------------------
# set -u example
# -----------------------------
echo "Using undefined variable:"
echo "$name"

# -----------------------------
# set -e example
# -----------------------------
echo "Running failed command:"
ls /wrong-directory

# -----------------------------
# set -o pipefail example
# -----------------------------
echo "Pipeline example:"
cat missingfile.txt | grep "hello"

echo "Script completed"
```
Example output: 
![alt text](image-2.png)

Definations: 

- set -e -> Exit script immediately if any command fails.Used for safer automation , CI/CD pipelines , production scripts

- set -u -> Treat undefined variables as errors.
prevents typos , unexpected empty variables

- set -o pipefail -> Makes pipeline fail if any command inside pipeline fails.

Q -> Why use strict mode?
- Strict mode helps fail fast, prevents hidden bugs, and makes automation scripts more reliable in production







