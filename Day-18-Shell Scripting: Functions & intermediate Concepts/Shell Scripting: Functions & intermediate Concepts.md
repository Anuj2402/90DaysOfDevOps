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

