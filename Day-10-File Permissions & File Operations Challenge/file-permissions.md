# Day 10 – File Permissions & File Operations Challenge

## Task 1: Create Files

1) Create empty file: 
 ```bash 
  touch devops.txt
  ```
2. Create notes.txt with content

  option (i) 
```bash
  echo "This is devops notes." > notes.txt
```
  option (ii)
  ```bash
   cat > notes.txt 
   type you text here
   Press CTRL + D
  ```
3. Create script.sh using vim
```bash 
    vim script.sh
```
Inside vim:
   ```bash 
    echo "Hello DevOps"
    save and exit 
   ```

4. Verify permissions:
```bash
ls -l devops.txt notes.txt script.sh
```
You will likely see:
```bash 
-rw-r--r-- devops.txt
-rw-r--r-- notes.txt
-rw-r--r-- script.sh
```

## Task 2: Read Files

1. Read notes.txt
```bash 
 cat notes.txt
```
2. Open script in read-only vim
```bash 
vim -R script.sh
```
3. First 5 lines of /etc/passwd
```bash 
head -n 5 /etc/passwd
```
4. Last 5 lines
```bash 
tail -n 5 /etc/passwd
```
## Task 3: Understand Permissions
```bash 
rwx    rwx   rwx
owner group others
```
Example:
```bash 
-rw-r--r--
```
Breakdown: 

-rw -> Owner/user can read and write 

r-- -> Group can read only 

r-- -> Others can read only


Check your files
```bash 
ls -l devops.txt notes.txt script.sh
```
Likely Answer : 
```bash 
-rw-r--r--
```
Who can:

    Owner → read, write

    Group → read

    Others → read

    Execute → no one
## Task 4: Modify Permissions

1. Make script executable
```bash 
chmod +x script.sh
```
check: 
```bash 
ls -l script.sh
```
Now we should see:
```bash 
-rwxr-xr-x
```
Run it:
```bash 
./script.sh
```
If error appears:
```bash 
bash: ./script.sh: Permission denied
```
→ execute bit missing
If error:
```bash
command not found
```
→ missing shebang (#!/bin/bash) 

2. Make devops.txt read-only for all
```bash 
chmod a-w devops.txt
```
Verify:
```bash 
ls -l devops.txt
```
Should look like:
```bash 
-r--r--r--
```
3. Set notes.txt to 640
```bash 
chmod 640 notes.txt
```
Verify:
```bash 
ls -l notes.txt
```
Should be:
```bash 
-rw-r-----

meaning 
owner -> read/write 
group -> read 
Other -> no access
```
4. Create directory project/
```bash 
mkdir project 
chmod 755 project 
```
verify : 
```bash 
ls -ld prject 
```
Should be:
```bash 
drwxr-xr-x

Directory meaning:

    Owner → full

    Group → read/execute

    Others → read/execute
```
# Task 5: Test Permissions

1. Try writing to read-only file
```bash 
echo "testing by writing " > devops.txt
```
You should get:
```bash 
Permission denied
```
2. Try executing file without execute permission
```bash 
chmod -x script.sh
./script.sh
```
Error:

```bash 
Permission denied
```
