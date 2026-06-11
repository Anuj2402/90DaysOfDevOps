# Task 6: Understand the Git Workflow


###  Q1-> What is the difference between git add and git commit?
- **git add** moves changes from the working directory to the staging area.
- **git commit** takes the staged changes and creates a premanent snapshot in the repository history 

Example: 
```bash 
git add file.txt
git commit -m "Add file.txt"

```
Here , **git add** prepares the file for commit and **git commit** records it in the git history 


### Q2-> What does the staging area do? Why doesn't Git commit directly?
 - The staging area acts as an intermediate step between the working directory and the repository. It allows developers to select specific changes for the next commit instead of committing everything at once. This helps create smaller, meaningful commits and keeps project history clean and organized.

 Example:
 ```bash 
 git add app.py
git commit -m "Fix authentication bug"

```
Only **app.py** is committed, even if other files were modified.

Quick Memory Trick
  - Working Directory = Where you edit files
  - Staging Area = Shopping cart
  - Commit = Purchase receipt

You can keep adding/removing items from the cart (git add) before finalizing the purchase (git commit).


### Q3 -> What information does git log show you?

- **git log** shows the commit history of your Git repository

- For each commit, it displays:
  
  - **Commit Hash** – A unique ID for the commit. 
  - **Author** – Who made the commit.
  - **Date** – When the commit was created.
  - **Commit Message** – A description of the changes
Example : 
```bash 
git log 
```
output : 
```
commit a1b2c3d4e5f6
Author: Anuj Rai <anuj@example.com>
Date:   Thu Jun 11 10:30:00 2026 +0530

    Add Git commands reference documentation

```

### Why is it useful?
 - Track project history
 - See who made changes
 - Find when changes were introduced
 - Identify specific commits for rollback or comparison

Compact View
```bash 
git log --oneline
```
Example:
```
a1b2c3d Add Git commands reference documentation
9f8e7d6 Initial commit
```
- **git log** displays the commit history of a repository, including the commit hash, author, date, and commit message for each commit. It helps track changes and understand the project's history.
