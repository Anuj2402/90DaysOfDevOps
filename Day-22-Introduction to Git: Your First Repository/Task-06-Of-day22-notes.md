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


### Q4 -> What is the .git/ folder and what happens if you delete it?

- The **.git/** folder is the heart of a git repository. It is a hidden directory created when you run :
```bash 
git init 
```
it contins all the infromation Git needs to Track your project 
 
 - Commit History 
 - Branches 
 - Tags 
 - Configuration 
 - Staging area (index)
 - Remote repository information
 - Onjects (files and commits stored by git )

 Example: 
 ```bash 
 ls -la .git 
 ```
 we might see
 ```
 HEAD -> Points to the current Branch 
 config -> Repository-Specific setting 
 objects/ -> Stores commits files and git data 
 refs/ -> Stores Branch and tag reference 
 index -> staging area information 
 hooks/ -> Automation scripts triggered by Git events

 ```
 ### What Happens If You Delete .git/?

 if we run : 
```bash
rm -rf 
```
Git Tacking is completely removed form that directory 

EFFECTs:

- All commit history is lost locally 
- All branches are lost locally
- Staging information is lost
- Remote repository configuration is lost
- Git commands such as git status and git log stop working

Example:
```bash 
git status
```
output: 
```
fatal: not a git repository (or any of the parent directories): .git
```
- Your project files (e.g., .md, .sh, .py) will still exist, but Git will no longer know anything about their history.

Summary: 
- The **.git/** folder is a hidden directory that contains all Git metadata, including commit history, branches, configuration, and the staging area. It is what makes a directory a Git repository. If the .git/ folder is deleted, the project files remain, but all Git history and tracking information are lost, and the directory is no longer recognized as a Git repository.

### Q5 -> What is the difference between a working directory, staging area, and repository?

This is a fundamental Git interview question.

### Git Has 3 Main Areas
```
Working Directory
        |
        | git add
        v
Staging Area
        |
        | git commit
        v
Repository

```
1. Working Directory
- The eorking directory is where you actually create and edit files. 
Example: 

```bash 
echo "Hello Git" > notes.txt
```
or edit **git-commands.md**.

At this point changes exist only on our computer and have not been staged or committed.

Think of it as your workspace.

2. Staging Area (Index)
- The staging area is a temporary area where you choose which changes will be included in the next commit.

Example:
```bash 
git add notes.txt
```
Now notes.txt is staged.

- This file is not yet part of the git history , but git knows it should be included in the next commmit 
 - Think of it as a shopping cart.

3. Repository
- The repository contains all committed snapshots and history.

```bash 
git commit -m "Add notes file"
```
- Now the changes are permanently recorded in Git history.

You can view them with:
```bash 
git log 
```
- Think of it as the library/archive of all your saved work.


Example Flow: 

Create or Modify a File
```bash 
echo "Git Basics" > notes.txt
```
File is in the Working Directory.

Stage the File
```bash 
git add notes.txt
```
File moves to the Staging Area.

Commit the File
```bash 
git commit -m "Add notes"
```
File is now stored in the Repository.


#### How to Check Each Area

- Working Directory vs Staging Area
```bash 
git diff 
```
Shows unstaged changes.

- Staging Area vs Repository
```bash 
git diff --staged
```
Shows staged changes waiting to be committed.

- Repository History
```bash 
git log 
```
Shows committed changes

**Working Directory**: The files you are currently editing on your local machine.

**Staging Area**: A temporary area where changes are prepared for the next commit using git add.

**Repository**: The Git database that stores committed snapshots and project history.

Workflow:
```bash 
git add file.txt
git commit -m "Add file"
```
- Here, file.txt moves from the working directory to the staging area, and then into the repository when committed.
