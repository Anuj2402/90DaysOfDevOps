# Task 1: For Loop: 

1. First do Vi For_loop.sh so that it will create that file and open vi terminal for you to write the script 

```bash 

#!/bin/bash

fruits=("apple" "banana" "orange" "mango" "papaya")

echo "All elements: ${fruits[@]}"
echo "Length of array: ${#fruits[@]}"

for fruit in "${fruits[@]}"
do
   echo "$fruit"
done

```

2. DO Vi count.sh it will open vi terminal for you to write the script 

```bash 

#!/bin/bash

for i in {1..10}
do
  echo "$i"
done

#Alternate method for of a c-type style 

#!/bin/bash

for (( i=1; i<=10; i++ ))
do
  echo "$i"
done

```
# Task 2: While Loop

```bash 
#!/bin/bash

read -p "Enter the number for countdown: " num

while [ $num -gt 0 ]
do
    echo "$num"
    num=$((num - 1))
done

echo "Done!"
```

