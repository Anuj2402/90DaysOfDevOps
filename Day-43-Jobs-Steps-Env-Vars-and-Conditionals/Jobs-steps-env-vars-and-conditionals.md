# Task 1: Multi-Job Workflow

### Step 1 — Create `multi-job.yml`

On our local machine , inside `github-actions-practice`

```bash 
cd ~/90DaysOfDevOps/github-actions-practice
touch .github/workflows/multi-job.yml
```
open it: 
```bash 
code .github/workflows/multi-job.yml
```

Write this indside the YAML file: 

```YAML 
name: Multi Job Workflow

on:
  push:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Build
        run: echo "Building the app"

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Test
        run: echo "Running tests"

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        run: echo "Deploying"
    
```

The important part Is
```YAML 
test:
  needs: Build 
```
- Means -> `test` cannot start until  `build` successfully finishes.

And
```YAML 
deploy: 
  needs: test 
```
- Means-> `Deploy` cannot start until `test` successfully finishes.

So the dependency chain is:
```
build
  │
  │ needs
  ▼
test
  │
  │ needs
  ▼
deploy
```

### Step 2 — Push it
Run: 
```bash 
git add .github/workflows/multi-job.yml
git commit -m "Add multi job workflow"
git push
```
Because the workflow has:
```YAML 
on: 
  push: 
```
the pipeline will start automatically 

### Step 3 — Check the Actions graph
Go to:

**GitHub → Actions → Multi Job Workflow**

we should see the dependency chain:
```
┌─────────┐
│  build  │
└────┬────┘
     │
     ▼
┌─────────┐
│  test   │
└────┬────┘
     │
     ▼
┌─────────┐
│ deploy  │
└─────────┘
```
- Notice that **all three jobs use separate runners**, but `needs` controls when they are allowed to start.

### Note for your learning
- `needs` creates dependencies between jobs. A job with `needs: build` waits for the build job to complete successfully before starting. This allows us to create controlled CI/CD stages such as **Build → Test → Deploy**.

### One important experiment
After you verify the successful run, change the build command temporarily to:
```YAML
run: |
  echo "Building the app"
  exit 1
```
Push it.

we will see : 
```
build  ❌
  ↓
test   ⏭️ skipped
  ↓
deploy ⏭️ skipped
```
OUTPUT: 
![alt text](image.png)

That's the real value of `needs:` **a failed build prevents downstream jobs from deploying.**

Then remove `exit 1` and push again.
