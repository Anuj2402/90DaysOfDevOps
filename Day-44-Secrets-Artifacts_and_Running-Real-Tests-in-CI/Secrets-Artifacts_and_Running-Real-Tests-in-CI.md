# Task 1: GitHub Secrets

### Step 1 — Create the GitHub Secret
Go to the Repository 

**GitHub → `github-actions-practice` → Settings → Secrets and variables → Actions**

Then: 
1. Click New repository secret
2. Name:
```
MY_SECRET_MESSAGE
```
3. For the value, enter any test message, for example:
```
This is my private CI secret
```
4. Click Add secret

After creating it, we should see something like:
```
MY_SECRET_MESSAGE
Updated just now
```

### Step 2 — Create the workflow
on our local machine 
```bash 
cd ~/github-actions-practice
# create 
touch .github/workflows/secrets.yml
```
Put this in 
```YAML 
name: GitHub Secrets

on:
  push:

jobs:
  check-secret:
    runs-on: ubuntu-latest

    steps:
      - name: Check if secret is set
        run: |
          if [ -n "${{ secrets.MY_SECRET_MESSAGE }}" ]; then
            echo "The secret is set: true"
          else
            echo "The secret is set: false"
          fi
```

Understand this

This : 
```YAML 
${{ secrets.MY_SECRET_MESSAGE }}
```
accesses the Github repository secret 

The shell: 
```bash 
-n 
```
checks whether the value is non-empty.

So we're checking:
```
Secret exists?
     │
     ├── Yes → The secret is set: true
     │
     └── No  → The secret is set: false
```

We are not printing the secret itself.

### Step 3 — Commit and push

```bash 
git add .github/workflows/secrets.yml
git commit -m "Add GitHub secrets workflow"
git push
```

Go to:

**GitHub → Actions → GitHub Secrets**

we  should see:
```
The secret is set: true
```
OUTPUT: 

### Step 4 — Your experiment
Once Step 3 works, we'll deliberately add:
```YAML 
- name: Try printing secret
  run: echo "${{ secrets.MY_SECRET_MESSAGE }}"
```
and observe what GitHub does.




