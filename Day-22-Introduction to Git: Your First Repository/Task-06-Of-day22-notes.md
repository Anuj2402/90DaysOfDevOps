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
