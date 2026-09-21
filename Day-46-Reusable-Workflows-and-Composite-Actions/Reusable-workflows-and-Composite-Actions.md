# Task 1: Understand `workflow_call`

This Task is introducing reusable workflows in GitHub Actions. The main Idea is : **Write a workflow once , then call it from other workflows instead of copying the same YAML repeatedly.**

1. What is a reusable workflow?
A **Reusable workflow** is a GitHub Action workflow that is designed to be called by another workflow.

For example, imagine we have the same Docker build process in 5 repositories:

```
Repo A ──┐
Repo B ──┤
Repo C ──┼──> Docker Build Workflow
Repo D ──┤
Repo E ──┘
```
Instead of copying the Docker workflow into every repository, we create it **once** and let the other workflows call it.

This reduces duplication and makes maintenance easier.

2. What is `workflow_call`?

`workflow_call` Tells the GitHub: **This workflow can be called by another workflow**

Example: 
```YAML 
on:
  workflow_call:
```
A normal workflow might have: 
```YAML 
on: 
  push:
```
A reusable workflow instead has: 
```YAML 
on:
  workflow_call: 
```
- we can also define **inputs and secrets** that the calling workflow can provide.

3. **Reusable workflow vs regular action** `uses:`

This is an important distinction.

we have already used actions like: 
```YAML 
steps:
  - uses: actions/checkout@v4
```
Here, `actions/checkout@v4` is an action used inside a step.

A reusable workflow is called at the **job level:**

```YAML 
jobs: 
  build:
    uses: ./.github/workflows/docker-build.yml
```
So:
```
Regular Action
     ↓
inside a step
     ↓
steps:
  - uses: ...

Reusable Workflow
     ↓
at job level
     ↓
jobs:
  build:
    uses: ...
```
A reusable workflow can contain **multiple jobs and multiple steps**, whereas an action is a reusable unit used within a step.

4. Where must the reusable workflow live?
It must be inside:
```
.github/workflows/
```
For example:
```
github-actions-practice/
│
├── .github/
│   └── workflows/
│       ├── main.yml
│       ├── docker-publish.yml
│       └── reusable-docker.yml
│
└── README.md
```

The reusable workflow file must be directly inside `.github/workflows` ;
subdirectories aren't supported.

5. The complete picture

Think of it like this:
```
Caller Workflow
     │
     │ calls
     ↓
Reusable Workflow
     │
     ├── Job 1
     │    ├── Step 1
     │    └── Step 2
     │
     └── Job 2
          ├── Step 1
          └── Step 2
```
The reusable workflow starts with:

```YAML 
name: Reusable Docker Build

on:
  workflow_call:
```
Then another workflow can call it.

In short:
`workflow_call` = **"Make this workflow available for other workflows to call."**




