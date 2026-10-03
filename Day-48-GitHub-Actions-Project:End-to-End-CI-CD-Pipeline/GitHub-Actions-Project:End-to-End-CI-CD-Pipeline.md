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
