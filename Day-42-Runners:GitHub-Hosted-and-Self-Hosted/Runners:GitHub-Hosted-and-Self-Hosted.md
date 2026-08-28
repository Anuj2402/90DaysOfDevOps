# Task 1: GitHub-Hosted Runners
we will create a new workflow with 3 independent jobs. Because they don't depend on each other , GitHub Actions can run them in parallel.

### Step 1: Create the workflow
From our Repo 
```bash 
cd ~/90DaysOfDevOps/github-actions-practice
# create 
touch .github/workflows/runners.yml
# open it 
code .github/workflows/runners.yml
```

Add. 
```YAML 
name: GitHub Hosted Runners

on:
  push:

jobs:
  ubuntu:
    runs-on: ubuntu-latest
    steps:
      - name: Print runner information
        run: |
          echo "OS: Linux"
          echo "Hostname: $(hostname)"
          echo "User: $(whoami)"

  windows:
    runs-on: windows-latest
    steps:
      - name: Print runner information
        shell: pwsh
        run: |
          Write-Host "OS: Windows"
          Write-Host "Hostname: $env:COMPUTERNAME"
          Write-Host "User: $env:USERNAME"

  macos:
    runs-on: macos-latest
    steps:
      - name: Print runner information
        run: |
          echo "OS: macOS"
          echo "Hostname: $(hostname)"
          echo "User: $(whoami)"
```
#### Why is Windows different?
Ubuntu and macOS runners use a Unix-like shell, so we can use:
```bash 
hostname
whoami
```
The Windows runner uses PowerShell, so we use:
```Powershell
$env:COMPUTERNAME
$env:USERNAME
```
### Step 2: Commit and push
Check the file : 
```bash
cat .github/workflows/runners.yml
# then 
git add .github/workflows/runners.yml
git commit -m "Add multi OS runner workflow"
git push
```

### Step 3: Watch all 3 jobs
Go to:

**GitHub → Actions → GitHub Hosted Runners**

we will see : 
```
GitHub Hosted Runners
        │
        ├── ubuntu       🐧
        ├── windows      🪟
        └── macos        🍎
```
- Because there is no `needs:` dependency between these jobs, GitHub can run them independently and in parallel.

we should eventually see : 
```
✓ ubuntu
✓ windows
✓ macos
```
Open each job and  check it's output 
For example, Ubuntu might show:
```
OS: Linux
Hostname: runner-xxxxx
User: runner
```
The exact hostname and user can vary because GitHub provides the runner environment for the job.

#### Notes: What is a GitHub-hosted runner

A **GitHub-hosted runner** is a virtual machine provided by GitHub that executes the jobs in a GitHub Actions workflow. GitHub manages the underlying machine, operating system environment, and runner software, so we don't need to maintain the runner ourselves.

#### GitHub-hosted vs self-hosted
```
GitHub-hosted
     │
     ▼
GitHub provides VM
     │
     ▼
GitHub manages it
     │
     ▼
our workflow runs
```
Whereas: 
```
Self-hosted
     │
     ▼
Your organization provides machine
     │
     ▼
Your organization manages it
     │
     ▼
Your workflow runs
```
#### Key point
when we write 
```YAML
runs-on: ubuntu-latest
```
we are essentially saying:
- **"GitHub, give this job an Ubuntu runner and execute my steps there."**
And with your three jobs:
```bash 
             Workflow
                 │
       ┌─────────┼─────────┐
       ▼         ▼         ▼
    Ubuntu    Windows     macOS
       │         │         │
       ▼         ▼         ▼
     Job 1     Job 2     Job 3
       │         │         │
       └─────────┼─────────┘
                 ▼
             Results

```
**Important:** The three jobs are separate runner environments. They don't share the same machine or filesystem.

OUTPUT Example: 
![alt text](image.png)

