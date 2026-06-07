# Task 1: Install and Configure Git(Global Infromarion Tracker)

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


# Task 3: Create Your Git Commands Reference

# Git Commands Reference

## Setup & Config

### `git --version`

**What it does:** Displays the installed Git version.

**Example:**

```bash
git --version
```

### `git config --global user.name`

**What it does:** Sets your Git username for all repositories.

**Example:**

```bash
git config --global user.name "Anuj Rai"
```

### `git config --global user.email`

**What it does:** Sets your Git email address for all repositories.

**Example:**

```bash
git config --global user.email "anuj@example.com"
```

### `git config --global --list`

**What it does:** Displays all global Git configuration settings.

**Example:**

```bash
git config --global --list
```

---

## Basic Workflow

### `git init`

**What it does:** Creates a new Git repository in the current directory.

**Example:**

```bash
git init
```

### `git add`

**What it does:** Adds files to the staging area.

**Example:**

```bash
git add git-commands.md
```

### `git commit`

**What it does:** Creates a snapshot of staged changes.

**Example:**

```bash
git commit -m "Add Git commands reference"
```

### `git push`

**What it does:** Uploads local commits to a remote repository.

**Example:**

```bash
git push origin main
```

### `git pull`

**What it does:** Downloads and integrates changes from a remote repository.

**Example:**

```bash
git pull origin main
```

---

## Viewing Changes

### `git status`

**What it does:** Shows the current state of the repository.

**Example:**

```bash
git status
```

### `git log`

**What it does:** Displays commit history.

**Example:**

```bash
git log
```

### `git log --oneline`

**What it does:** Displays commit history in a compact format.

**Example:**

```bash
git log --oneline
```

### `git diff`

**What it does:** Shows unstaged changes between the working directory and staging area.

**Example:**

```bash
git diff
```

### `ls -la`

**What it does:** Lists all files, including hidden files such as `.git`.

**Example:**

```bash
ls -la
```

# Task 4: Stage and Commit

Step 1: Check Current Status

- Before staging, see what Git knows about your repository:

```bash 
git status
```
Expected output:
```
Untracked files:
  git-commands.md

```
- What it means: Git sees the file, but it is not being tracked yet.

Step 2: Stage the File
- Add the file to the staging area:

```bash
git add git-commands.md
```
Or stage all the created and mofified files:
```bash 
git add .
```
- What it means: You're telling Git, "Include this file in the next commit."

Step 3: Check What's Staged

Run:
```bash 
git status
```
Expected output:
```bash 
Changes to be committed:
  new file: git-commands.md
  ```

To see exactly what is staged:

```bash 
git diff --staged
```
- What it means: Shows the content that will be included in the next commit.

Step 4: Commit with a Meaningful Message

Create your first commit:
```bash 
git commit -m "Add Git commands reference documentation"
```
Expected output:
```bash 
[main abc1234] Add Git commands reference documentation
 1 file changed, 50 insertions(+)
 create mode 100644 git-commands.md
 ```
 - What it means: Git created a snapshot of your staged changes.

 Step 5: View Commit History

 View detailed history:

 ```bash 
 git log
 ```
 Example:
 ```
 commit abc1234...
Author: Anuj Rai <anuj@example.com>
Date: ...

    Add Git commands reference documentation
```
Step 6: View Compact Commit History
```bash 
A cleaner format used daily by developers:
```
Example:
```
anujrai@anujrai-mn4561 90DaysOfDevOps % git log --oneline
ab6b6dc (HEAD -> main, origin/main) Day 22 task 3 Git Command referance completed
6d38d6a Day 22 Taks 2 completed
6bd5825 Git Intro -> Day22 Task 1 is completed
7aa5c5a Update README to remove training 
```




