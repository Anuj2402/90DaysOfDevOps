# Task 1: Understanding Branches

Q1-> What is a branch in Git?
- A **Branch** in a git is a independent line of devlopment that let you work on a changes without affecting the main codebase. 
- Think of it as creating a separate workspace where you can experiment, add features, or fix bugs safely.

Visual Example: 
```
main
  |
  A --- B --- C

feature-login
          \
           D --- E
```
- main is the primary branch.
- feature-login is a separate branch created from main
- Changes on **feature-login** do not affect main until you merge them

## View Branches
```bash 
git branch
```
Example:
```
* main
  feature-login
  
```
- *indicates the current branch.


Q2-> Why do we use branches instead of committing everything to main?

- We use branches so that developers can work on new features, bug fixes, or experiments without affecting the stable main branch.

- If everyone committed directly to main, the codebase could become unstable, broken, or difficult to manage.

Example Scenario: 

Imagine your application is running in production

Current state:
```
main
 |
 A --- B --- C
 
 ```
 - Now you need to build a login feature.
 
 Bad Approach: Commit Directly to main
```
main
 |
 A --- B --- C --- D --- E --- F
 ```
 Problems:
 - The feature may be incomplete.
 - Other developers see unfinished code.
 - Production deployments can break.
 - Rolling back becomes harder.

 Better Approach: Use a Branch
 ```
 main
 |
 A --- B --- C
              \
               D --- E --- F
                 feature-login
```
Benefits:
- main remains stable.
- we can test safely 
- Other developers can continue working.
- The feature can be reviewed before merging

When ready:
```bash 
git merge feature-login
```
### Team Collaboration Example
- Suppose three developers are working:
```bash 
main
├── feature-login
├── feature-payment
└── bugfix-auth
```
- Each developer works independently.

Without branches:
```bash 
main
├── login changes
├── payment changes
├── bug fixes
├── experimental code
└── incomplete work

```
- The repository quickly becomes messy and unstable.

DevOps Perspective

In professional environments:
```
main      -> Production-ready code
develop   -> Integration branch
feature/* -> New features
hotfix/*  -> Production fixes
release/* -> Release preparation
```
This branching strategy enables:
- Code reviews
- CI/CD testing
- Safe deployments
- Controlled releases

Summary: 
- Branches allow developers to work on features, bug fixes, and experiments in isolation without affecting the stable main branch. They enable parallel development, safer testing, code reviews, and easier collaboration. Once changes are tested and approved, they can be merged into main

Q3 -> What is HEAD in Git?
- HEAD is a special pointer that tells Git where you are currently working.

- In most cases, HEAD points to the latest commit on your current branch.

Example: 

Suppose your repository looks like this:
```
A --- B --- C  (main)
              ^
            HEAD
```
Here:
- main points to commit C
- HEAD points to main
- Any new commit will be added after C

How to See HEAD
Run:
```bash 
cat .git/HEAD
```
Output:
```
ref: refs/heads/main
```
This means:
```bash
HEAD --> main --> latest commit
```
What Happens When You Commit?

Before:
```
A --- B --- C  (HEAD -> main)
```
After:
```
A --- B --- C --- D  (HEAD -> main)
```
- When you create commit D, both main and HEAD move forward.

Switching Branches: 

Suppose you create a branch:
```bash 
git checkout -b feature-login
```
Now:
```bash 
A --- B --- C  (main)
              \
               D  (HEAD -> feature-login)
```
- HEAD now points to feature-login because that is your current branch.

Useful command: 
```bash 
git rev-parse HEAD
```
- Outputs the commit hash that HEAD currently points to.

Summary: 
- HEAD is a special pointer that identifies the current branch and commit that Git is working on. Normally, it points to the latest commit of the active branch. When new commits are created, HEAD moves forward with the branch. In a detached HEAD state, it points directly to a specific commit instead of a branch.

Q4-> What happens to your files when you switch branches?

- When you switch branches, Git changes the files in your working directory to match the state of the branch you're switching to

Example

Suppose you have two branches:

main:
```
app.py
README.md

```

feature-login:
```
app.py
README.md
login.py
```

When you're on main:
```bash 
git checkout main
ls
```
Output:
```
app.py
README.md
```

Now switch to feature-login:

```bash 
git checkout feature-login
```
Output:
```
app.py
README.md
login.py
```
- Git automatically updates your files so your working directory matches that branch.

What If Files Are Different?

main:
```
config.txt
Version 1
```

feature-login:

```
config.txt
Version 2
```
When you switch branches:

```bash 
git checkout feature-login
```
- Git replaces Version 1 with Version 2.


Summary:
- When you switch branches, Git updates the working directory and staging area to match the state of the target branch. Files that exist only on that branch appear, modified files are updated to that branch's version, and files not present on the target branch may disappear. If uncommitted changes would be overwritten, Git prevents the branch switch until the changes are committed, stashed, or discarded.


# Task 2: Branching Commands — Hands-On

Created A **devops-git-practice** repo for practice : 

i. List all Branches on The repo : 

```bash 
git branch 
```
Example output:
![alt text](image.png)

ii. Create a New Branch Called **feature-1**

```bash 
git branch -b feature-1
```
Verify:
```bash 
git branch 
```

Output:
![alt text](image-1.png)

iii. Switch to feature-1
```bash 
git checkout feature-1
```
Verify:
```bash 
git branch 
```
Outout : 
![alt text](image-2.png)

iv. Create and Switch to feature-2 in One Command
Using checkout: 

```bash 
git checkout -b feature-2
```
Or using the modern command:
```bash 
git switch -c feature-2
```
Verify:
```bash 
git branch 
```
output: 
![alt text](image-3.png)
![alt text](image-4.png)

v. Try git switch
Move back to feature-1:
```bash 
git switch feature-1
```

Move to main:
```bash 
git switch main
```
Output : 
![alt text](image-5.png)
![alt text](image-6.png)

### Difference Between git switch and git checkout


- **git checkout** -> Used for switching branches and restoring files

- **git switch**  -> Used only for switching branches (simpler and safer)

vi. Make a Commit on feature-1
Switch to feature-1:
```bash 
git switch feature-1
```
Add a text file 
![alt text](image-7.png)


![alt text](image-8.png)

vii. Verify the Commit Exists on feature-1
```bash 
git log --oneline
```
Output: 
```bash 
sarah@dev01 devops-git-practice on  feature-1 ➜  git log --oneline
8a607c3 (HEAD -> feature-1) Added one Text file to feature-1 branch
4842ab8 (master, feature-2) Initial commit

sarah@dev01 devops-git-practice on  feature-1 ➜  

```


viii. Switch Back to main
```bash 
git switch main or master 
git checkout main or master 
```
check history: 
```bash 
git log 
```

Output: 

![alt text](image-9.png)
- This proves the commit exists only on feature-1.

iX. Delete a Branch You No Longer Need

Switch to main first:
```bash 
git checkout main/master 
```
Delete feature-2:
```bash 
git branch -d feature-2
```
List branches:
```bash
git branch 
```
Output: 
![alt text](image-10.png)


x. Add Branching Commands to git-commands.md

