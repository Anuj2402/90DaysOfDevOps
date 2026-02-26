## Task 1: Understanding Ownership

i. Created Few files to check Ownership Infomation
```bash 
touch ownership1.txt
echo "Testing ownership" > ownership2.txt
mkdir ownership_dir
```
now run : 
```bash 
ls -l 
```
You should see something like:
```bash 
-rw-r--r-- 1 root root   0 Feb 27 ownership1.txt
-rw-r--r-- 1 root root  18 Feb 27 ownership2.txt
drwxr-xr-x 2 root root 4096 Feb 27 ownership_dir
```

ii. Understand the Columns
Format:
```bash 
permissions links owner group size date filename
```
Example line:
```bash 
-rw-r--r-- 1 root root 18 Feb 27 ownership2.txt
               ↑    ↑
             owner group
```
Q. What is “links”?

The links field shows the number of hard links to that file or directory.

A hard link is another directory entry that points to the same inode (same actual data on disk).

Q. Why is it used?
 
 For Files-> if the link count is greater than 1, 
 
it means:
    The same file content is referenced by multiple filenames.
    Deleting one filename does not delete the data until the link count becomes 0.


iii. See Numeric Ownership (Important Concept)
RUN : 
```bash 
ls -ln 
```
Now you’ll see:
```bash 
-rw-r--r-- 1 0 0 18 Feb 27 ownership2.txt
```
Linux internally uses:

    UID = 0

    GID = 0

Names are just mapping.

Q-> What's the difference between owner and group?

 Difference Between Owner and Group

- Owner is a single user who has primary control over the file.

- Group represents multiple users who can share access.

Linux checks permissions in this order:

- Owner permissions

- Group permissions

- Others permissions

The first rwx applies to owner, second to group, third to others.

## Task 2: Basic chown Operations (20 minutes)

Step 1 — Create Users (If Needed)

```bash 
useradd tokyo 
useradd berlin
```
verify: 
```bash
id tokyo
id berlin
```
Step 2 — Create the File
```bash 
touch devops-file.txt
```
Verify:
```bash 
ls -l devops-file.txt
```
You’ll see:
```bash 
-rw-r--r-- 1 root root 0 Feb 27 devops-file.txt
````

Current owner = root,   
Current group = root

Step 3 — Change Owner to tokyo
```bash 
chown tokyo devops-file.txt
```
Verify:
```bash 
ls -l devops-file.txt
```
Now we should see:
```bash 
-rw-r--r-- 1 tokyo root 0 Feb 27 devops-file.txt
```
Notice:
- Owner changed
- Group stayed root

Step 4 — Change Owner to berlin
```bash 
chown berlin devops-file.txt
```
verify: 
```bash 
ls -l devops-file.txt
```
Now:
```bash 
-rw-r--r-- 1 berlin root 0 Feb 27 devops-file.txt
```
# Important Concept

```bash 
chown username filename
```
- Changes user owner only 

To change both user and group:
```bash 
chown user:group filename

example: 

chown berlin:berlin devops-file.txt
```

Q -> What does chown do?
- chown changes the user ownership of a file. Only root can change file ownership. It can also modify group ownership when specified in user:group format.

## Task 3: Basic chgrp Operations (15 minutes)

Step 1 — Create File
```bash 
touch team-notes.txt
```
Check current ownership:
```bash 
ls -l team-notes.txt
```
You will see something like:
```bash 
-rw-r--r-- 1 root root 0 Feb 27 team-notes.txt
```
owner = root 
group = root 

Step 3 — Create Group

Check if group exists:
```bash 
getent group heist-team
```
If nothing prints, create it:
```bash 
groupadd heist-team
```
Verify:
```bash 
getent group heist-team
```
You should see something like:
```bash 
heist-team:x:1005:
```
Step 4 — Change File Group
Now change only the group:
```bash 
chgrp heist-team team-notes.txt
```
(Alternative method)
```bash 
chown :heist-team team-notes.txt
```
Step 5 — Verify
```bash 
ls -l team-notes.txt
```
Now you should see:
```bash 
-rw-r--r-- 1 root heist-team 0 Feb 27 team-notes.txt
```
- Owner remains root
- Group changed to heist-team

Q -> What is chgrp?
-  Changes only group ownership

 - Owner remains unchanged

Can be used by:

- root (for any group)

 - normal user (only to groups they belong to)

Q -> What is the difference between chown and chgrp?
- chown changes file owner (and optionally group).
- chgrp changes only the group ownership of a file.

## Task 4: Combined Owner & Group Change (15 minutes)
Make sure required users & group exist:
```bash 
getent passwd professor
getent passwd berlin
getent group heist-team
```
If they don’t exist, create them (since you're root):
```bash 
useradd professor
useradd berlin
groupadd heist-team
```

Verify again:
```bash 
id professor
id berlin
getent group heist-team
```
Step 1 — Create File
```bash 
touch project-config.yaml
```
Check current ownership:
```bash 
ls -l project-config.yaml
```
You’ll see something like:
```bash 
-rw-r--r-- 1 root root 0 Feb 27 project-config.yaml
```
Step 2 — Change Owner AND Group (One Command)
```bash 
syntax -> chowm user:group filename 

chown professor:heist-team project-config.yaml
```
Verify:
```bash 
ls -l project-config.yaml
```
Expected:
```bash 
-rw-r--r-- 1 professor heist-team 0 Feb 27 project-config.yaml

owner is professor 
group is heist-team 
```
Step 3 — Create Directory
```bash 
mkdir app-logs
```
Check:
```bash 
ls -ld app-logs
```
Step 4 — Change Owner & Group for Directory
```bash 
chown berlin:heist-team app-logs
```
Verify:
```bash 
ls -ld app-logs
```
Expected:
```bash 
drwxr-xr-x 2 berlin heist-team 4096 Feb 27 app-logs
```
Important Concept 

- When changing ownership for directories in real environments:

Recursive change (VERY COMMON)
```bash 
chown -R user:group directory/

example: 
chown -R berlin:heist-team app-logs/
```

Q-> How do you change ownership recursively?
```bash 
- chown -R user:group directory/
```
## Task 5: Recursive Ownership (20 minutes)
Step 0 — Safety Check
Make sure required user & group exist:
```bash 
getent passwd professor
getent group planners
```
If not present:
```bash 
useradd professor
groupadd planners
```
Verify:
```bash 
id professor
getent group planners
```
Step 1 — Create Directory Structure
```bash 
mkdir -p heist-project/vault
mkdir -p heist-project/plans
touch heist-project/vault/gold.txt
touch heist-project/plans/strategy.conf
```
Verify structure:
```bash 
ls -lR heist-project/
```
You should see something like:
```bash 
heist-project/
vault  plans

heist-project/vault:
gold.txt

heist-project/plans:
strategy.conf

```
- All owned by root root initially.

Step 2 — Change Ownership Recursively
This is the key command:
```bash 
chown -R professor:planners heist-project/
```
What -R Does
- -R = Recursive

It changes:

- Parent directory

- All subdirectories

- All files inside them

Step 3 — Verify Everything Changed

Run:
```bash 
ls -lR heist-project/
```
Expected output pattern:
```bash 
drwxr-xr-x 3 professor planners ...

heist-project/vault:
-rw-r--r-- 1 professor planners gold.txt

heist-project/plans:
-rw-r--r-- 1 professor planners strategy.conf
```
Q-> What does **chown -R** do?
- It recursively changes ownership of a directory and all its contents

Q-> How do you verify recursive ownership?
- Use **ls -lR directory/**

## Task 6: Practice Challenge (20 minutes)
Step 0 — Safety First
Make sure users exist:
```bash 
getent passwd tokyo
getent passwd berlin
getent passwd nairobi
```
If missing, create them:
```bash 
useradd tokyo
useradd berlin
useradd nairobi
```
Check groups:
```bash 
getent group vault-team
getent group tech-team
```
If missing:
```bash 
groupadd vault-team
groupadd tech-team
```
Step 1 — Create Directory
```bash 
mkdir bank-heist
```
Step 2 — Create Files
```bash 
touch bank-heist/access-codes.txt
touch bank-heist/blueprints.pdf
touch bank-heist/escape-plan.txt
```
Verify structure:
```bash 
ls -l bank-heist/
```
Initially everything will be owned by:
```bash 
root root
```
Step 3 — Set Ownerships

1. access-codes.txt
```bash 
chown tokyo:vault-team bank-heist/access-codes.txt
```
2. blueprints.pdf
```bash 
chown berlin:tech-team bank-heist/blueprints.pdf
```
3. escape-plan.txt
```bash 
chown nairobi:vault-team bank-heist/escape-plan.txt
```
Step 4 — Verify
```bash 
ls -l bank-heist/
```
Expected output pattern:
```bash 
-rw-r--r-- 1 tokyo   vault-team access-codes.txt
-rw-r--r-- 1 berlin  tech-team  blueprints.pdf
-rw-r--r-- 1 nairobi vault-team escape-plan.txt
```

