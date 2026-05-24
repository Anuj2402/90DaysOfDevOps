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


