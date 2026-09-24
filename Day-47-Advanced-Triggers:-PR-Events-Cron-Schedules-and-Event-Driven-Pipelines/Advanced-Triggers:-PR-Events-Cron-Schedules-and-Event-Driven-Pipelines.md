# Task 1: Pull Request Event Types

This Task is about learning the **PR lifecycle** and how GitHub Actions eacts to different PR events.

### Step 1 — Create the workflow
Create:
```
.github/workflows/pr-lifecycle.yml
```
Start with this:
```YAML 
name: PR Lifecycle

on: 
  pull_request: 
    types: 
     - opened
     - synchronize 
     - reopened
     - closed 
```
#### What do these events mean?
| Event         | When it happens                          |
| ------------- | ---------------------------------------- |
| `opened`      | A new PR is created                      |
| `synchronize` | New commits are pushed to an existing PR |
| `reopened`    | A previously closed PR is reopened       |
| `closed`      | The PR is closed or merged               |

Notice that merged PRs also generate  `closed`. GitHub doesn't have a separate `merged` activity type.

That's why later we'll check:
```YAML 
github.event.pull_request.merged == true 
```
to distinguish:
```
closed + merged = true  → PR was merged
closed + merged = false → PR was simply closed
```
### Step 2 — Add the job
Under the trigger,  we will add:
```YAML 
jobs:
  pr-info: 
    runs-on: ubuntu-latest
    
    
    steps: 
      - name: Show PR information
        run: | 
        echo "Event type: ${{ github.event.action }}
        echo "PR title: ${{ github.event.pull_request.title }}
        echo "Source branch: ${{ github.event.pull_request.head.ref }}"
        echo "Target branch: ${{ github.event.pull_request.base.ref }}"
```
so far our complete file should be : 
```YAML 
name: PR Lifecycle

on:
  pull_request:
    types:
      - opened
      - synchronize
      - reopened
      - closed

jobs:
  pr-info:
    runs-on: ubuntu-latest

    steps:
      - name: Show PR information
        run: |
          echo "Event type: ${{ github.event.action }}"
          echo "PR title: ${{ github.event.pull_request.title }}"
          echo "PR author: ${{ github.event.pull_request.user.login }}"
          echo "Source branch: ${{ github.event.pull_request.head.ref }}"
          echo "Target branch: ${{ github.event.pull_request.base.ref }}"
```

Now let's add the merged-only condition.

### Step 2 — Add this step
under our existing `Show PR information` step, add:
```YAML 
- name: PR was merged
    if: github.event.action == 'closed' && github.event.pull_request.merged == true
    run: echo "This PR was merged successfully!"
```
our complete workflow should now be:
```YAML 
name: PR Lifecycle

on:
  pull_request:
    types:
      - opened
      - synchronize
      - reopened
      - closed

jobs:
  pr-info:
    runs-on: ubuntu-latest

    steps:
      - name: Show PR information
        run: |
          echo "Event type: ${{ github.event.action }}"
          echo "PR title: ${{ github.event.pull_request.title }}"
          echo "PR author: ${{ github.event.pull_request.user.login }}"
          echo "Source branch: ${{ github.event.pull_request.head.ref }}"
          echo "Target branch: ${{ github.event.pull_request.base.ref }}"

      - name: PR was merged
        if: github.event.action == 'closed' && github.event.pull_request.merged == true
        run: echo "This PR was merged successfully!"
```
#### Understand the condition
This part: 
```YAML
if: github.event.action == 'closed'
```
means the PR must be **closed.**

And:
```YAML 
github.event.pull_request.merged == true
```
means it must have been **merged**, not simply closed.
      
So:
```
PR opened
   ↓
merged step ❌

PR updated
   ↓
merged step ❌

PR reopened
   ↓
merged step ❌

PR closed without merge
   ↓
merged step ❌

PR merged
   ↓
merged step ✅
```
#### Now commit and push the workflow
```bash 
git add .github/workflows/pr-lifecycle.yml
git commit -m "Add PR lifecycle workflow"
git push
```

### Now let's test it properly

### Step 1 — Create a test branch
```bash 
git checkout -b test-pr-lifecycle
```
Then make a small change, for example:
```bash 
echo "PR lifecycle test" >> README.md
```
Commit it:
```bash 
git add README.md
git commit -m "Test PR lifecycle"
```
Push the branch:
```bash 
git push -u origin test-pr-lifecycle
```
Important: The push itself still won't `trigger pr-lifecycle.yml`.

### Step 2 — Create a Pull Request
Go to GitHub → your repository → Pull requests → New pull request.

Select:
```
base:   main
compare: test-pr-lifecycle
```
Create the PR.
Now the `opened` event should trigger the workflow. 🟢

OUTPUT: 
![alt text](image.png)

Perfect! ✅ The **opened event worked exactly as expected.

our screenshot shows:
```
Event type: opened
PR title: Test PR lifecycle
PR author: Anuj2402
Source branch: test-pr-lifecycle
Target branch: main
```
And importantly:
```
PR was merged
```
was skipped ⏭️ — that's correct because the PR has only been opened, not merged.

#### Now test the next event: `synchronize`

Don't merge the PR yet.

Make another small change on our `test-pr-lifecycle` branch:

```bash 
echo "Testing synchronize event" >> README.md
git add README.md
git commit -m "Test PR synchronize"
git push
```
Because we're pushing a new commit to an existing PR, GitHub should trigger:
```
Event type: synchronize
```
OUTPUT:
![alt text](image-1.png)

Perfect! ✅ The `synchronize` event worked.

our screenshot shows:
```
Event type: synchronize
PR title: Test PR lifecycle
PR author: Anuj2402
Source branch: test-pr-lifecycle
Target branch: main
```
And the PR was merged step is correctly skipped because this PR hasn't been merged yet.

So far we've verified:
```
PR created
   ↓
opened       ✅

New commit pushed to PR
   ↓
synchronize  ✅
```

#### Next: test `closed`

Now go to the PR on GitHub and merge it.
When you merge it, the workflow should trigger again with:
```
Event type: closed
```
And because the PR was actually merged:
```
github.event.pull_request.merged == true
```
the final step should run and print:
```
This PR was merged successfully!
```
OUTPUT: 
![alt text](image-3.png)
Perfect! ✅ Task 1 is fully verified.
our final screenshot confirms the `closed` event:
```
Event type: closed
PR title: Test PR lifecycle
PR author: Anuj2402
Source branch: test-pr-lifecycle
Target branch: main
```
And most importantly:
```
PR was merged
This PR was merged successfully!
```

