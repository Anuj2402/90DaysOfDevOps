# Task 1: Install and Configure Git

Q1-> Verify Git is installed on your machine

Command we will use to verify that is below : 
```bash 
git --version 
```
output: 
```
anujrai@anujrai-mn4561 90DaysOfDevOps % git --version 
git version 2.50.1 (Apple Git-155)
anujrai@anujrai-mn4561 90DaysOfDevOps % 
```

### Q2-> Set up your Git identity — name and email: 
- To set up your Git identity (username and email), run these commands in your terminal:

Set Username:
```bash 
git config --global user.name "Your Name"

```
Set Email:
```bash 
git config --global user.email "your.email@example.com"
```

Q3-> Verify Configuration:
- Check that the values were saved:
```bash 
git config --global user.name
git config --global user.email
```
Or view all Git configuration:
```bash 
git config --global --list

```
### Understanding --global
- **--global** → applies to all Git repositories for your user account.
- Without **--global**, the setting applies only to the current repository.

To check where Git is reading the configuration from:
```bash
git config --list --show-origin
```


# Task 2: Create Your Git Project

Step 1: Create a New Project Directory
```bash 
mkdir devops-git-practice # This command will create a folder called devops-git-practice 
cd devops-git-practice # This command will change the directory and move to the devops-git-practice directory 

Pwd # we can verify your present working directory 

```

Step 2: Initialize a Git Repository

```bash
git init
```
Expected output:

```
Initialized empty Git repository in /path/to/devops-git-practice/.git/
```
- Git has now created a hidden **.git** directory that stores all repository metadata

Step 3: Check Repository Status
```bash 
git status 
```
Expected output:
```
On branch main

No commits yet

nothing to commit (create/copy files and use "git add" to track)

```
### Understanding the Output: 

- On branch main -> You are currently working on the main branch.

- No commits yet -> The repository has been initialized, but no snapshots (commits) have been created.

- nothing to commit -> Git is not tracking any files yet.

Step 4: View Hidden Files
```bash 
ls -la 
```

Example Output:
```
.
..
.git

```
- The .git directory is hidden because its name starts with a dot (.).

Step 5: Explore the .git Directory

```bash 
ls -la .git
```
You may see something like:
```
HEAD
config
description
hooks/
info/
objects/
refs/
```

## Understanding Important Git Files

HEAD: 
```bash 
cat .git/HEAD
```
Output:
```
ref: refs/heads/main
```
- HEAD points to the branch you're currently working on.

config: 
```bash
cat .git/config
```
- Contains repository-specific Git settings.
Example:
```
[core]
    repositoryformatversion = 0
    filemode = true
```

objects/ : 
```bash 
ls .git/objects
```
Stores all Git data:

 - Commits
 - Trees
 - Blobs (file contents)

Initially it will be mostly empty.

refs/
```bash 
ls -R .git/refs
```
Stores references to:

- Branches
- Tags

Example:
```bash 
heads/
tags/
```
hooks/
```bash 
ls .git/hooks
```
Contains sample scripts that Git can execute automatically.

Examples:

 - pre-commit
 - pre-push
 - post-merge

These are commonly used in DevOps and CI/CD pipelines.

### What You Learned: 
- **mkdir** -> Create a directory
- **git init** -> Initialize a Git repository
- **git status** -> Check repository state
- **ls -la** -> Show hidden files
- **.git/** -> Git's internal database
- **HEAD** -> Current branch pointer
- **objects/** -> Stores Git data
- **refs/** -> Stores branch/tag references
- **hooks/** -> Automation scripts

