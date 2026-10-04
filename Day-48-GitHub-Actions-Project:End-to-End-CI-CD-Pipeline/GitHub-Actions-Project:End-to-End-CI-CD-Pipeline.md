# Task 1: Set Up the Project Repo

1. We are going to use our EXISTING Repo `github-actions-practice`

2. Add a simple app — pick any one , we are picking our GO-CHAT-APP From DAY-36
Let's use our Go chat app from Day 36 for this task. We'll connect it to your CI/CD practice and use the same project you already Dockerized.

our previous project is in ~/chat-app. It has main.go, go.mod, go.sum, index.html, and history.html. It uses port 8080 and has a chat-history API endpoint we can use for a health check.

3. Add a `Dockerfile` and a `basic test` (even a script that curls the health endpoint counts)

`DockerFile` -> Already existed in the repo (from when we fixed the placeholder-app mismatch) — multi-stage, non-root, Alpine-based

`Basic test (curl health endpoint)` -> `scripts/health_check.sh` — builds the image, spins up real `MySQL` + the `app`, polls `/api/chat-history` with `curl`, reports `pass/fail`, cleans up automatically

We proved it works with a real run that printed `Health check passed!`.

4. Rewrite `README.md`

```bash 
cat > /tmp/write_readme.py << 'PYEOF'
content = """[![Docker Build and Push](https://github.com/Anuj2402/github-actions-practice/actions/workflows/docker-build-push.yml/badge.svg)](https://github.com/Anuj2402/github-actions-practice/actions/workflows/docker-build-push.yml)

# github-actions-practice

A three-tier real-time chat application, Dockerized and wired up with a GitHub Actions CI/CD pipeline that builds, tests, and publishes the image to Docker Hub.

## What it does

- **Frontend** -- static HTML/CSS/JS chat UI (index.html) and a chat history browser (history.html), both served directly by the Go backend.
- **Backend** -- a Go server exposing a WebSocket endpoint (/ws) for real-time messaging and a REST endpoint (/api/chat-history) for querying past conversations.
- **Database** -- MySQL, storing every message sent, queried via GORM.

Two users connect over WebSocket with a from/to username pair, see their prior conversation history replayed on connect, and exchange messages live. The protocol (ws:// vs wss://) is chosen dynamically based on how the page itself was loaded, so it works correctly behind both plain HTTP and TLS-terminating proxies.

## Project layout

FENCE
.
|-- main.go                        # Go backend: WebSocket handler + REST API + MySQL via GORM
|-- go.mod / go.sum
|-- index.html                     # Chat UI
|-- history.html                   # Chat history UI
|-- Dockerfile                     # Multi-stage build, small, non-root runtime image
|-- .dockerignore
|-- scripts/
|   `-- health_check.sh            # Builds the image, runs it against a real MySQL
|                                   # instance, and curls the REST endpoint to confirm
|                                   # the app actually starts and responds correctly
`-- .github/workflows/
    `-- docker-build-push.yml      # CI: build, test, tag, push to Docker Hub
FENCE

## Running locally

FENCEBASH
docker build -t chat-app .
FENCE

The app needs MySQL to start (it fails fast if it can't connect). Configuration is entirely via environment variables -- no hardcoded credentials:

| Variable | Default | Description |
|---|---|---|
| APP_PORT | 8080 | Port the server listens on |
| DB_HOST | 127.0.0.1 | MySQL host |
| DB_PORT | 3306 | MySQL port |
| DB_USER | root | MySQL user |
| DB_PASSWORD | (empty) | MySQL password |
| DB_NAME | chatdb | Database name |

See scripts/health_check.sh for a working example of running the app alongside a MySQL container.

## Testing

FENCEBASH
./scripts/health_check.sh
FENCE

This builds the image, starts a real MySQL container, starts the app pointed at it, waits for the app to respond, and curls /api/chat-history to confirm it returns a valid response. Everything is cleaned up automatically afterward, whether the check passes or fails.

## CI/CD

On every push to main, GitHub Actions:
1. Checks out the code
2. Builds the Docker image
3. Logs in to Docker Hub using repo secrets (DOCKER_USERNAME, DOCKER_TOKEN)
4. Tags the image as latest and sha-<short-commit-hash>
5. Pushes both tags to Docker Hub -- only when the push is to main (feature branches and PRs build the image but don't publish it)

Pull the published image:

FENCEBASH
docker pull anujkumar007/chat-app:latest
FENCE
"""

content = content.replace("FENCEBASH", "```bash")
content = content.replace("FENCE", "```")

with open("README.md", "w") as f:
    f.write(content)

print("README.md written successfully")
PYEOF
```
Run it
```bash 
cd ~/github-actions-practice
python3 /tmp/write_readme.py
```
Verify
```bash 
cat README.md
wc -l README.md
```
Commit everything
```bash 
git add Dockerfile scripts/health_check.sh README.md
git status
```

- `Dockerfile` isn't listed because it was already correct from our earlier fix (no changes needed there), so only `README.md` and `scripts/health_check.sh` are staged. That's expected and correct.

Commit and push
```bash 
git commit -m "Add real health-check test script and rewrite README"
git push origin main
```

# Task 2: Reusable Workflow — Build & Test

### Step 1: Create the reusable workflow
Create the YAML file 
```bash 
touch .github/workflows/reusable-build-test.yml
```
Add this to YAML 
```YAML 
name: Reusable Build & Test

on:
  workflow_call:
    inputs:
      go_version:
        description: 'Go version to use'
        type: string
        default: '1.22'
      run_tests:
        description: 'Whether to run tests'
        type: boolean
        default: true
    outputs:
      test_result:
        description: 'Result of the test run: passed or failed'
        value: ${{ jobs.build-test.outputs.test_result }}

jobs:
  build-test:
    runs-on: ubuntu-latest
    outputs:
      test_result: ${{ steps.set-result.outputs.test_result }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Go
        uses: actions/setup-go@v5
        with:
          go-version: ${{ inputs.go_version }}

      - name: Install dependencies
        run: go mod download

      - name: Build
        run: go build -o /tmp/chat-server .

      - name: Run tests
        id: run-tests
        if: ${{ inputs.run_tests }}
        run: go test ./... -v

      - name: Set output
        id: set-result
        if: always()
        run: |
          if [ "${{ inputs.run_tests }}" != "true" ]; then
            echo "test_result=skipped" >> "$GITHUB_OUTPUT"
          elif [ "${{ steps.run-tests.outcome }}" == "success" ]; then
            echo "test_result=passed" >> "$GITHUB_OUTPUT"
          else
            echo "test_result=failed" >> "$GITHUB_OUTPUT"
          fi



```
This is a reusable GitHub Actions workflow for our `Go chat application`. It builds the application, optionally runs tests, and returns a result (passed, failed, or skipped) to the workflow that calls it.

##### Explanation of each section

1. Workflow name and trigger
```YAML 
name: Reusable Build & Test

on:
  workflow_call:
  
```
- `name` -> is the display name of the workflow in GitHub Actions.
- `workflow_call` -> makes this workflow reusable.
- It doesn't run automatically on every push by itself. Another workflow must call it.

For example, a caller workflow could use:
```YAML 
jobs:
  build:
    uses: ./.github/workflows/reusable-build-test.yml
```
- The filename in that example is illustrative; it must match the actual file you save.

2. Inputs

```YAML 
inputs:
  go_version:
    description: 'Go version to use'
    type: string 
    default: '1.22' # Selects which Go version to install

  run_tests:
    description: 'Whether to run tests'
    type: boolean
    default: true # Controls whether tests execute
```
- Inputs are parameters supplied by the caller.
For example, the caller could pass:
```YAML 
with:
  go_version: '1.23'
  run_tests: false
```
- This requests` Go 1.23` and skips the test step.
- If the caller doesn't supply either input, the defaults apply.

3. Workflow output
```YAML 
outputs:
  test_result:
    description: 'Result of the test run: passed or failed'
    value: ${{ jobs.build-test.outputs.test_result }}
```
This exposes a value from the job to the caller workflow.
There are two levels of output here:
- **Job output**: `build-test` makes `test_result` available.
- **Workflow output**: `workflow_call.outputs` exposes that job output to the caller
- Think of it as returning a value from a function.
The expression:
```YAML 
${{ jobs.build-test.outputs.test_result }}
```
Means: retrieve the `test_result` output from the `build-test` job.

Note: The description says `passed or failed`, but the actual workflow also returns `skipped`. It would be more accurate to mention all three states.

4. The `build-test` job
```YAML 
jobs:
  build-test:
    runs-on: ubuntu-latest
    outputs:
      test_result: ${{ steps.set-result.outputs.test_result }}
```
- `jobs` defines the jobs in the workflow.
- `build-test` is the job ID.
- `runs-on: ubuntu-latest` selects a GitHub-hosted Ubuntu runner.
- `outputs` exposes the value generated by a step in this job.

Notice this expression:
```YAML 
${{ steps.set-result.outputs.test_result }}
```
- It retrieves the output named `test_result` from the step with ID `set-result`.

Now let's follow the steps inside this job.

5. Step-by-step execution

Step 1: Checkout code
```YAML 
- name: Checkout code
  uses: actions/checkout@v4
```
- Downloads our repository's code into the runner's working directory.
Without this step, the runner wouldn't have our `main.go`, `go.mod`, and other project files.

Step 2: Set up Go
```YAML 
- name: Set up Go
  uses: actions/setup-go@v5
  with:
    go-version: ${{ inputs.go_version }}
```
- Installs the Go version requested by the caller.
If `go_version` is `1.22`, the runner sets up `Go 1.22.`

Step 3: Install dependencies
```YAML 
- name: Install dependencies
  run: go mod download
```
- Downloads the dependencies declared in your Go module files.If a required package can't be downloaded, this step fails and the subsequent normal steps won't run.

Step 4: Build
```YAML 
- name: Build
  run: go build -o /tmp/chat-server .
```
- Compiles our Go application and creates a binary at `/tmp/chat-server.`
- `-o` specifies the output file.
- `.` tells Go to build the package in the current directory.
This checks whether our code compiles. It doesn't start the chat server.

Step 5: Run tests

```YAML 
- name: Run tests
  id: run-tests
  if: ${{ inputs.run_tests }}
  run: go test ./... -v
```
This is the optional step.
- `id:` run-tests gives the step an ID so other steps can refer to its result.
- `if` decides whether to execute it.
- `go test ./...` runs tests in the current module and its subpackages.
- `-v` displays verbose test output.
If `run_tests` is `false`, this step is skipped.

Step 6: Set output
```YAML 
- name: Set output
  id: set-result
  if: always()
  run: |
    if [ "${{ inputs.run_tests }}" != "true" ]; then
      echo "test_result=skipped" >> "$GITHUB_OUTPUT"
    elif [ "${{ steps.run-tests.outcome }}" == "success" ]; then
      echo "test_result=passed" >> "$GITHUB_OUTPUT"
    else
      echo "test_result=failed" >> "$GITHUB_OUTPUT"
    fi
```
This is the most important logic in our workflow.
`if: always()` tells GitHub to run this step even if an earlier step failed or was skipped.

`steps.run-tests.outcome` reads the outcome of the step identified by run-tests.

`"$GITHUB_OUTPUT"` is a special file used by GitHub Actions to publish step outputs. Writing `test_result=passed` to it makes that value available through `steps.set-result.outputs.test_result.`


### Step 3: Add a real test file

Let's close that gap with a minimal real test — a unit test for getEnv(), since it's pure logic with no DB dependency, perfect for a fast go test.
```bash 
cat > main_test.go << 'EOF'
package main

import (
	"os"
	"testing"
)

func TestGetEnv_ReturnsEnvValueWhenSet(t *testing.T) {
	os.Setenv("TEST_KEY", "custom_value")
	defer os.Unsetenv("TEST_KEY")

	got := getEnv("TEST_KEY", "fallback_value")
	want := "custom_value"

	if got != want {
		t.Errorf("getEnv() = %q, want %q", got, want)
	}
}

func TestGetEnv_ReturnsFallbackWhenUnset(t *testing.T) {
	os.Unsetenv("TEST_KEY_UNSET")

	got := getEnv("TEST_KEY_UNSET", "fallback_value")
	want := "fallback_value"

	if got != want {
		t.Errorf("getEnv() = %q, want %q", got, want)
	}
}

func TestGetEnv_ReturnsFallbackWhenEmptyString(t *testing.T) {
	os.Setenv("TEST_KEY_EMPTY", "")
	defer os.Unsetenv("TEST_KEY_EMPTY")

	got := getEnv("TEST_KEY_EMPTY", "fallback_value")
	want := "fallback_value"

	if got != want {
		t.Errorf("getEnv() = %q, want %q", got, want)
	}
}
EOF
```
### Step 4: Verify it passes locally
```bash 
go test ./... -v
```

OUTPUT: 
```
anujrai@anujrai-mn4561 github-actions-practice % go test ./... -v
=== RUN   TestGetEnv_ReturnsEnvValueWhenSet
--- PASS: TestGetEnv_ReturnsEnvValueWhenSet (0.00s)
=== RUN   TestGetEnv_ReturnsFallbackWhenUnset
--- PASS: TestGetEnv_ReturnsFallbackWhenUnset (0.00s)
=== RUN   TestGetEnv_ReturnsFallbackWhenEmptyString
--- PASS: TestGetEnv_ReturnsFallbackWhenEmptyString (0.00s)
PASS
ok      chatapp 0.801s
```
### Step 5: Add test files to .dockerignore
```bash 
grep -q "_test.go" .dockerignore || echo "*_test.go" >> .dockerignore
cat .dockerignore
```
### Step 6: Commit and push
```bash 
git add main_test.go .dockerignore .github/workflows/reusable-build-test.yml
git status
```

