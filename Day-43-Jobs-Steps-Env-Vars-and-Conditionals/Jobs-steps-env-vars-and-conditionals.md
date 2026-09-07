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

# Task 2: Environment Variables

### Step 1 — Create the workflow
on our local machine

```bash 
cd ~/90DaysOfDevOps/github-actions-practice
touch .github/workflows/env-vars.yml
```
Open it: 
```bash 
code .github/workflows/env-vars.yml
```
Add: 

```YAML 
name: Environment Variables

on:
  push:

env:
  APP_NAME: myapp

jobs:
  show-vars:
    runs-on: ubuntu-latest

    env:
      ENVIRONMENT: staging

    steps:
      - name: Print variables
        env:
          VERSION: 1.0.0
        run: |
          echo "APP_NAME: $APP_NAME"
          echo "ENVIRONMENT: $ENVIRONMENT"
          echo "VERSION: $VERSION"
          echo "COMMIT SHA: $GITHUB_SHA"
          echo "ACTOR: $GITHUB_ACTOR"
```

### Step 2 — Understand the three levels

1. Workflow Level 

```YAML 
env: 
  APP_NAME: myapp 
```
This is available to all jobs and steps in this workflow

```
Workflow
   │
   ├── Job 1 → APP_NAME ✓
   ├── Job 2 → APP_NAME ✓
   └── Job 3 → APP_NAME ✓
```

2. Job level
```YAML 
jobs:
  show-vars:
    env:
      ENVIRONMENT: staging
```
This variable is available to all steps inside `show-vars.`
```
show-vars
   │
   ├── Step 1 → ENVIRONMENT ✓
   ├── Step 2 → ENVIRONMENT ✓
   └── Step 3 → ENVIRONMENT ✓
```
3. Step level

```YAML
steps:
  - name: Print variables
    env:
      VERSION: 1.0.0
```
`VERSION` is available only inside that particular step

```
Step: Print variables
        │
        └── VERSION ✓
```

### Step 3 — GitHub context variables

These are provided automatically by GitHub.

Commit SHA
```bash 
$GITHUB_SHA
```
This identifies the commit that triggered the workflow.

Actor

```bash 
$GITHUB_ACTOR
```
This identifies the GitHub user who triggered the workflow.

So this:
```YAML
echo "COMMIT SHA: $GITHUB_SHA"
echo "ACTOR: $GITHUB_ACTOR"
```
might produce:
```
APP_NAME: myapp
ENVIRONMENT: staging
VERSION: 1.0.0
COMMIT SHA: 8f31c...
ACTOR: Anuj2402
```
The SHA will obviously be different for each commit.

OUTPUT: 

![alt text](image-1.png)

### Step 4 — Push it

```bash 
git add .github/workflows/env-vars.yml
git commit -m "Add environment variables workflow"
git push
```
Then go to:

**GitHub → Actions → Environment Variables**

Open the job and check the Print variables step.

Expected result
```
✓ APP_NAME: myapp
✓ ENVIRONMENT: staging
✓ VERSION: 1.0.0
✓ COMMIT SHA: <40-character SHA>
✓ ACTOR: <GitHub username>
```
### Notes
Workflow-level variables are available throughout the workflow. Job-level variables are available to all steps within that job. Step-level variables are available only to that specific step. GitHub also provides context/environment variables such as `GITHUB_SHA` for the commit SHA and `GITHUB_ACTOR` for the user who triggered the workflow.

Easy way to remember
```
Workflow env
     ↓
  Job env
     ↓
 Step env
```

**Scope gets narrower as you go down.**


# Task 3: Job Outputs
This task is about passing data from one job to another.

we will use two jobs: 
```
generate-date
      │
      │ output: today
      ▼
show-date
```
### Step 1 — Create the workflow
on our local machine:

```bash 
cd ~/90DaysOfDevOps/github-actions-practice
touch .github/workflows/job-outputs.yml
```
Open it:
```bash 
code .github/workflows/job-outputs.yml
```
Put this in it:
```YAML 
name: Job Outputs

on:
  push:

jobs:
  generate-date:
    runs-on: ubuntu-latest

    outputs:
      today: ${{ steps.date.outputs.today }}

    steps:
      - name: Get today's date
        id: date
        run: echo "today=$(date +'%Y-%m-%d')" >> "$GITHUB_OUTPUT"

  show-date:
    needs: generate-date
    runs-on: ubuntu-latest

    steps:
      - name: Print date
        run: echo "Today's date is ${{ needs.generate-date.outputs.today }}"
```

### Step 2 — Understand the important pieces

1. Create the output
Inside the first job:
```YAML 
outputs:
  today: ${{ steps.date.outputs.today }}
```
We're saying:

- The job's output called today comes from the step output called today.

2. Give the step an ID

```YAML 
- name: Get today's date
  id: date 
```
The `id` allows us to reference this step later:
like
```
step.date 
```

3. Create the step output

This is the key command 
```bash 
echo "today=$(date +'%Y-%m-%d')" >> "$GITHUB_OUTPUT"
```
For example, it might create:
```
today=2026-09-02
```
GitHub Actions reads `$GITHUB_OUTPUT` and makes that value available as a step output.

So:
```
Step
 │
 ├── id: date
 │ 
 └── outputs: # this is job level 
       today = 2026-09-02
```

### Step 3 — Make the output available to another job
The second job has:
```YAML 
needs: generate-date
```
This does Two things: 
1. Make `show-date `wait for `generate-date`
2. Allows `show-date` to access the first job's outputs.

We then access it using
```YAML 
${{ needs.generate-date.outputs.today }}
```
Break it down:
```
needs
  ↓
generate-date
  ↓
outputs
  ↓
today
```

### Step 4 — Push the workflow
Run:
```bash 
git add .github/workflows/job-outputs.yml
# then 
git commit -m "Add job outputs workflow"
# then 
git push

```
Go to : **GitHub → Actions → Job Outputs**

we should see:
```
generate-date ✓
      │
      ▼
show-date ✓
```
OUTPUT: 
![alt text](image-2.png)

Open **show-date**
we should see something like : 
```
Today's date is 2026-09-02
```
OUTPUT: 
![alt text](image-3.png)

### Notes
The mental model: I'd remember GitHub Actions outputs like this:

```
┌──────────────────────────────┐
│ Job: generate-date            │
│                              │
│  ┌────────────────────────┐  │
│  │ Step: date             │  │
│  │                        │  │
│  │ today = 2026-09-05     │  │
│  └───────────┬────────────┘  │
│              │               │
│              │ step output   │
│              ▼               │
│       Job output: today      │
└──────────────┬───────────────┘
               │
               │ needs
               ▼
┌──────────────────────────────┐
│ Job: show-date               │
│                              │
│ needs.generate-date.outputs  │
│ .today                       │
│                              │
│          ↓                   │
│    2026-09-05                │
└──────────────────────────────┘

```

- **When someone pushes code, run generate-date, have its date step produce today's date, expose that value as a job output, wait for that job to finish, then let show-date consume that output and print it**.

- **Job outputs allow one job to pass dynamically generated data to another job. This is useful when a later job needs information produced by an earlier job, such as a version number, image tag, build ID, artifact name, or deployment information.**

#### Real world CI/CD example: 
Imagine:
```
Build
 │
 ├── Build Docker image
 └── Generate image tag
          │
          ▼
      Test
          │
          ▼
      Deploy
```
The build job could output:
```
IMAGE_TAG=1.5.2
```
Then the deploy job could use:
```YAML
${{ needs.build.outputs.image_tag }}
```
to deploy exactly that image.

Remember this syntax
```YAML 
outputs:
  name: ${{ steps.step-id.outputs.value }}
```
Then from another job:
```YAML 
${{ needs.job-id.outputs.name }}
```
So the complete flow is:
```
Step output
     ↓
Job output
     ↓
needs.<job>.outputs.<name>
     ↓
Another job
```

# Task 4: Conditionals

### Part 1 — Step runs only on `main`

First we will create the workflow: 
```bash 
cd ~/github-actions-practice
touch .github/workflows/conditionals.yml
```
Put this in 
```YAML 
name: Conditionals

on:
  push:
  pull_request:

jobs:
  conditional-steps:
    runs-on: ubuntu-latest

    steps:
      - name: Normal step
        run: echo "This always runs"

      - name: Main branch step
        if: github.ref == 'refs/heads/main'
        run: echo "This runs only on main"

```
#### What is happening?
This line is important part
```YAML 
if: github.ref == 'refs/heads/main'
```
Github Checks: Is the current Git reference `refs/heads/main?`
if Yes -> step runs ✅
If no -> step is skipped ⏭️

For a push to another branch such as `feature/test:`
```
Normal step       → runs
Main branch step  → skipped
```
For a push to `main:`
```
Normal step       → runs
Main branch step  → runs
```
#### Push It nOw
```bash 
git add .github/workflows/conditionals.yml
git commit -m "Add conditional workflow"
git push
```

OUTPUT: 
![alt text](image-4.png)

### Part 2 — Run a step only when the previous step fails

Now let's intentionally create a failing step and then use the `failure() ` condition.

Update our workflow to:
```YAML 
name: Conditionals

on:
  push:
  pull_request:

jobs:
  conditional-steps:
    runs-on: ubuntu-latest

    steps:
      - name: Normal step
        run: echo "This always runs"

      - name: Main branch step
        if: github.ref == 'refs/heads/main'
        run: echo "This runs only on main"

      - name: Intentional failure
        run: |
          echo "This step will fail"
          exit 1

      - name: Failure handler
        if: failure()
        run: echo "The previous step failed!"
```
#### New concept
This:
```YAML 
if: failure()
```
- Means : **Run this step if a previous step in the job has failed.**
Our flow is:
```
Normal step
     ↓
Main branch step
     ↓
Intentional failure ❌
     ↓
Failure handler ✅
```
Normally, when a step fails, GitHub Actions stops executing subsequent steps.

But:
```YAML 
if: failure()
```
allows the failure-handling step to execute.
One important thing:

The overall job will still be marked failed because `Intentional failure` failed.

we'll therefore see something like:
```
Normal step          ✅
Main branch step     ✅
Intentional failure  ❌
Failure handler      ✅
Complete job         ❌
```
That's expected.

#### Push it : 
Modify the workflow, commit and push:
```bash 
git add .github/workflows/conditionals.yml
git commit -m "Add failure condition"
git push
```

OUTPUT: 
![alt text](image-5.png)


##### Imp Q -> How do you execute a cleanup or notification step when an earlier step fails?

I can use the `failure()` conditional expression with `if:.` For example, `if: failure()` makes the step execute when a previous step in the job has failed. This is useful for failure notifications, collecting logs, or cleanup.

### Part 3 — Job runs only on Push
Now we'll create a second job that runs only when the workflow was triggered by a `push`, and doesn't run for a pull request.


Add this job underneath our existing `conditional-steps` job:
```YAML 
  push-only-job:
    if: github.event_name == 'push'
    runs-on: ubuntu-latest

    steps:
      - name: Push only
        run: echo "This job runs only on push events"
```
so our workflow should now look like:
```YAML 
name: Conditionals

on:
  push:
  pull_request:

jobs:
  conditional-steps:
    runs-on: ubuntu-latest

    steps:
      - name: Normal step
        run: echo "This always runs"

      - name: Main branch step
        if: github.ref == 'refs/heads/main'
        run: echo "This runs only on main"

      - name: Intentional failure
        run: |
          echo "This step will fail"
          exit 1

      - name: Failure handler
        if: failure()
        run: echo "The previous step failed!"

  push-only-job:
    if: github.event_name == 'push'
    runs-on: ubuntu-latest

    steps:
      - name: Push only
        run: echo "This job runs only on push events"
```

#### New concept
This condition:
```YAML 
if: github.event_name == 'push'
```
checks how the **workflow was triggered**

GitHub provides the event name through:
```
github.event_name
```
Examples:
```
Push event       → github.event_name = "push"
Pull request     → github.event_name = "pull_request"
```
Therefore:
```
Push
 │
 ├── conditional-steps
 └── push-only-job ✅
```
But:
```
Pull Request
 │
 ├── conditional-steps
 └── push-only-job ⏭️ skipped
```
Commit and push:
```bash 
git add .github/workflows/conditionals.yml
git commit -m "Add push only job"
git push
```
OUTPUT: 
![alt text](image-6.png)

### Part 4 — continue-on-error: true
Now let's learn the last concept.

Add this step after our `Normal step`:
```YAML 
      - name: Allowed failure
        continue-on-error: true
        run: |
          echo "This step will fail"
          exit 1

      - name: After allowed failure
        run: echo "The workflow continues!"
```
So that section becomes:
```YAML 
name: Conditionals

on:
  push:
  pull_request:

jobs:
  conditional-steps:
    runs-on: ubuntu-latest

    steps:
      - name: Normal step
        run: echo "This always runs"

      - name: Allowed failure
        continue-on-error: true
        run: |
          echo "This step will fail"
          exit 1

      - name: After allowed failure
        run: echo "The workflow continues!"

      - name: Main branch step
        if: github.ref == 'refs/heads/main'
        run: echo "This runs only on main"

      - name: Intentional failure
        run: |
          echo "This step will fail"
          exit 1

      - name: Failure handler
        if: failure()
        run: echo "The previous step failed!"
```

#### commit ans push 
```bash 
git add .github/workflows/conditionals.yml
git commit -m "Add continue on error condition"
git push
```
OUTPUT: 
![alt text](image-7.png)

#### What does continue-on-error: true do?
Normally:
```
Step A ✅
   ↓
Step B ❌
   ↓
Step C ⏭️
```
The failure stops the normal flow.

With:
```YAML 
continue-on-error: true
```
we get:
```
Step A ✅
   ↓
Step B ❌  ← allowed failure
   ↓
Step C ✅  ← continues
```
The key distinction for interviews:

`continue-on-error` vs `failure()`

| Feature                   | Purpose                                           |
| ------------------------- | ------------------------------------------------- |
| `if: failure()`           | **Run something because a failure occurred**      |
| `continue-on-error: true` | **Allow a failing step to not stop the workflow** |

A real-world example:
```YAML 
- name: Run optional security scan
  continue-on-error: true
  run: ./security-scan.sh
```
we might want the security scan to report problems but **not block the rest of a development pipeline.**

#### imp Q-> What does `continue-on-error: true` do in GitHub Actions?

`continue-on-error: true` allows a step that fails to continue with subsequent steps instead of stopping the job. It's useful for non-critical or optional checks where we want to record the failure but don't want it to block the pipeline.

# Task 5: Putting It Together

The goal is to combine what you've just learned:
```
Push to any branch
       │
       ├──────────────┐
       ↓              ↓
     lint            test
       │              │
       └──────┬───────┘
              ↓
           summary
              │
       ┌──────┴──────┐
       ↓             ↓
     main         feature
```
The important concept here is that `lint` and `test` should run in parallel, while `summary` waits for both.


### Step 1 — Create the workflow
From our repository:
```bash 
cd ~/github-actions-practice
# Create the file:
vi  .github/workflows/smart-pipeline.yml

```
For now, let's build only the **trigger + two parallel jobs**.

Put this in the file:
```YAML 
name: Smart Pipeline

on:
  push:

jobs:
  lint:
    runs-on: ubuntu-latest

    steps:
      - name: Lint
        run: echo "Running lint"

  test:
    runs-on: ubuntu-latest

    steps:
      - name: Test
        run: echo "Running tests"
```

#### Understand this carefully

The trigger:
```YAML 
on:
  push:
```
means the workflow runs whenever there is a push, regardless of whether the branch is:

```bash 
main
develop
feature/login
feature/payment
anything-else
```
We deliberately don't specify:
```YAML
branches:
  - main
```
because the task says any branch.

      
#### Why are `lint` and `test` parallel?
Notice that neither job has:
```YAML 
needs:
```
So GitHub Actions can start them independently:
```
             Push
               │
        ┌──────┴──────┐
        ↓             ↓
      lint           test
      2 sec          3 sec
        │             │
        └──────┬──────┘
               ↓
            summary
```
Later we'll add:

```YAML 
needs:
  - lint
  - test
```
to `summary`.

That will make `summary` wait for both jobs.

#### Save the file and run:
```bash
git add .github/workflows/smart-pipeline.yml
git commit -m "Add smart pipeline"
git push
```
OUTPUT: 
![alt text](image-8.png)

### Step 2 — Add the summary job

Keep our existing `lint` and `test` jobs and add this underneath them:

```YAML 
  summary:
    needs:
      - lint
      - test

    runs-on: ubuntu-latest

    steps:
      - name: Show branch type
        run: |
          if [ "$GITHUB_REF_NAME" = "main" ]; then
            echo "This is a main branch push"
          else
            echo "This is a feature branch push"
          fi

      - name: Show commit message
        run: echo "Commit message: ${{ github.event.head_commit.message }}"
```

So the complete workflow should now be:
```YAML 
name: Smart Pipeline

on:
  push:

jobs:
  lint:
    runs-on: ubuntu-latest

    steps:
      - name: Lint
        run: echo "Running lint"

  test:
    runs-on: ubuntu-latest

    steps:
      - name: Test
        run: echo "Running tests"

  summary:
    needs:
      - lint
      - test

    runs-on: ubuntu-latest

    steps:
      - name: Show branch type
        run: |
          if [ "$GITHUB_REF_NAME" = "main" ]; then
            echo "This is a main branch push"
          else
            echo "This is a feature branch push"
          fi

      - name: Show commit message
        run: echo "Commit message: ${{ github.event.head_commit.message }}"
```
#### Understand `needs`

This is the most important part:
```YAML 
needs: 
  - lint: 
  - test: 
```
It means:
```
             Push
               │
        ┌──────┴──────┐
        ↓             ↓
      lint           test
        │             │
        └──────┬──────┘
               ↓
            summary
```
summary waits for both `lint` and `test`.

If either one fails, `summary` will normally be skipped.

Why use `$GITHUB_REF_NAME?`

GitHub provides:
```bash 
$GITHUB_REF_NAME
```
which gives the branch name.

For example:
```
Push to main
→ GITHUB_REF_NAME = main

Push to feature/login
→ GITHUB_REF_NAME = feature/login
```
So our shell `if` determines whether this is a main or feature branch push.
      
Save and push:
```bash 
git add .github/workflows/smart-pipeline.yml
git commit -m "Add summary job"
git push
```

OUTPUT: 
![alt text](image-9.png)
