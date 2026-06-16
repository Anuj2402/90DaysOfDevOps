# Task 1: Git Merge — Hands-On
### Create a new branch feature-login from main and add a couple of commits
Make sure you're on main:
```bash 
git switch main
```

Create and switch to the branch:
```bash 
git switch -c feature-login
```
Create a file:
```bash 
echo "Login Feature - Step 1" > login.txt
git add login.txt
git commit -m "Add login file"
```
Add another change:
```bash 
echo "Login Feature - Step 2 and version2 with more security" >> login.txt
git add login.txt
git commit -m "Update login feature"
```
Verify:
```bash 
git log --oneline
```
Output: 
![alt text](image.png)


### Switch back to main and merge feature-login into main

```bash 
git switch main 
```

Merge:
```bash 
git merge feature-login
```

### Observe the merge — did Git do a fast-forward merge or a merge commit?
Check:
```bash 
git log --oneline --graph --decorate
```
You should see:

![alt text](image-1.png)

Git will most likely show:
```
Fast-forward
```
- because no new commits were made on main after creating feature-login

### Create another branch feature-signup, add commits to it — but also add a commit to main before merging

Create branch:
```bash 
git switch -c feature-signup
```
Create file:
```bash 
echo "Signup Feature" > signup.txt
git add signup.txt
git commit -m "Add signup feature"
```
Switch back to main:
```bash 
git switch master/main 
     OR 
git checkout master 
```
Make a new commit on main/ master:
```bash 
echo "Main branch update" > main.txt
git add main.txt
git commit -m "Update main branch"
```
Output Log : 
![alt text](image-2.png)

### Merge feature-signup into main — what happens this time?

Run:
```bash 
git merge feature-signup
```
Now check:
```bash 
git log --oneline --graph --decorate
```
OUTPUT: 
![alt text](image-3.png)
- So Git cannot fast-forward.It creates a new commit: a1019c6 ->which combines both histories.
- Git created a merge commit (a1019c6) because both master and feature-signup contained new commits after they diverged.


# Git Merge Notes

## What is a Fast-Forward Merge?

A fast-forward merge happens when the target branch has not changed since the feature branch was created.

Example:

```text
main
A---B

feature-login
     \
      C---D
```

After merge:

```text
A---B---C---D
```

Git simply moves the `main` pointer forward and does not create a merge commit.

---

## When Does Git Create a Merge Commit Instead?

Git creates a merge commit when both branches contain new commits after they diverged.

Example:

```text
A---B---F (main)
     \
      C---D (feature-signup)
```

After merge:

```text
      C---D
     /     \
A---B---F---M
```

`M` is the merge commit.

---

## What is a Merge Conflict?

A merge conflict occurs when Git cannot automatically decide which changes to keep.

This usually happens when the same line of the same file is modified in two different branches.

Example:

```text
<<<<<<< HEAD
Main branch version
=======
Feature branch version
>>>>>>> feature-branch
```

The developer must manually edit the file, resolve the conflict, and commit the resolution.


### Bonus: Create an Intentional Merge Conflict
```bash 
git switch -c conflict-demo
echo "Feature Version" > conflict.txt
git add conflict.txt
git commit -m "Feature change"

git switch main
echo "Main Version" > conflict.txt
git add conflict.txt
git commit -m "Main change"

git merge conflict-demo
```
- Git will stop with a conflict and ask you to resolve it manually. This demonstrates exactly what a merge conflict looks like in practice.

Output: 
![alt text](image-4.png)

Let's Resolve this merge conflict now 

Step 1: Check the Conflicted File

Open the file:
```bash 
cat conflict.txt
```
You'll see something like:

```
<<<<<<< HEAD
Main Version
=======
Feature Version
>>>>>>> conflict-demo
```

Meaning
```
<<<<<<< HEAD
```
- Current branch (master) version

```
=======

```
- Separator

```
>>>>>>> conflict-demo
```

- Version from conflict-demo

Step 2: Decide What You Want

Option A: Keep Both

Edit conflict.txt:
```
Main Version
Feature Version
```

Option B: Keep Main Only

```
Main Version
```

Option C: Keep Feature Only

```
Feature Version
```

Step 3: Mark Conflict as Resolved

After editing the file:
```bash 
git add conflict.txt
```

Check status:
```bash 
git status
```
You should see:
```
All conflicts fixed but you are still merging.
```
Step 4: Complete the Merge
```bash 
git commit -m "Resolve merge conflict between master and conflict-demo"
```
- Git creates a merge commit.

Step 5: Verify
```bash 
git log --oneline --graph --decorate
```
You'll see something like:
```
* abc1234 Resolve merge conflict between master and conflict-demo
|\
| * def5678 Feature change
* | ghi9012 Main change
|/
```


Output:
![alt text](image-5.png)

