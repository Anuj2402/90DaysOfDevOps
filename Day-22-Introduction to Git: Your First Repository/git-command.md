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

## Branching

### `git branch`

**What it does:** Lists all local branches.

**Example:**

```bash
git branch
```

### `git checkout -b`

**What it does:** Creates and switches to a new branch.

**Example:**

```bash
git checkout -b feature-login
```

