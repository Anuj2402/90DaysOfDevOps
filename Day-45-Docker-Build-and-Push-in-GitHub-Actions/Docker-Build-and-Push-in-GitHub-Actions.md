# Task 1: Prepare

1. I am using the Go-Chat- APP That i Dockerized on Day 36 

2. Added the Dockerfile to our github-actions-practice repo

```dockerfile 
# syntax=docker/dockerfile:1

FROM golang:1.22-alpine AS builder

WORKDIR /src

RUN apk add --no-cache git ca-certificates

COPY go.mod ./
RUN go mod download

COPY main.go ./
COPY index.html ./
COPY history.html ./

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o /out/chat-server main.go

FROM alpine:3.20 AS runtime

RUN apk add --no-cache ca-certificates tzdata \
    && addgroup -S appgroup \
    && adduser -S -G appgroup -H -h /app appuser

WORKDIR /app

COPY --from=builder /out/chat-server ./chat-server
COPY --from=builder /src/index.html ./index.html
COPY --from=builder /src/history.html ./history.html

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --spider http://127.0.0.1:8080/ || exit 1

ENTRYPOINT ["./chat-server"]

```
3.  Make sure DOCKER_USERNAME and DOCKER_TOKEN secrets are set from Day 44
- Secrectes are Set already 

# Task 2: Build the Docker Image in CI

```bash 
touch .github/workflows/docker-publish.yml
```
put it in YAML 
```YAML 
name: Docker Build and Push

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Build Docker image
        uses: docker/build-push-action@v6
        with:
          context: .
          file: ./Dockerfile
          push: false
          tags: |
            ${{ secrets.DOCKER_USERNAME }}/chat-app:latest
            ${{ secrets.DOCKER_USERNAME }}/chat-app:${{ github.sha }}
```
#### Understand the Flow 

1. Trigger

```YAML 
on:
  push:
    branches: [main]
```
- Runs when you `push to main`.

2.  Runner 
```YAML 
runs-on: ubuntu-latest
```
- GitHub gives us an Ubuntu machine.

3. Checkout
```YAML 
uses: actions/checkout@v4
```
- Downloads our GitHub code into the runner.

4. Buildx
```YAML
uses: docker/setup-buildx-action@v3
```
- Sets up Docker's build system.

5. Build Docker image
```YAML
uses: docker/build-push-action@v6
```
- Builds our Docker image.

Important part:
```YAML 
context: .
file: ./Dockerfile
push: false
```
- `context: .` -> use the current repo 
- `file: ./Dockerfile` -> use this Dockerfile
- `push: false` -> build only, don't upload to Docker Hub

6. Tags
```YAML 
tags: |
  ${{ secrets.DOCKER_USERNAME }}/chat-app:latest
  ${{ secrets.DOCKER_USERNAME }}/chat-app:${{ github.sha }}
```
This gives the image two names:
```
username/chat-app:latest
username/chat-app:<commit-sha>
```
The important thing to understand now:
This workflow builds the Docker image but does NOT push it to Docker Hub.


OutPut:
![alt text](image.png)

- This workflow builds a Docker image, but currently does NOT push it to Docker Hub.

# Task 3: Push to Docker Hub
```YAML
name: Docker Build and Push

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Get short commit SHA
        id: vars
        run: echo "sha_short=$(git rev-parse --short HEAD)" >> "$GITHUB_OUTPUT"

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v6
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: |
            ${{ secrets.DOCKER_USERNAME }}/chat-app:latest
            ${{ secrets.DOCKER_USERNAME }}/chat-app:sha-${{ steps.vars.outputs.sha_short }}
```

#### Let's Understand the Above YAML for Push to Docker Hub

1. Get Short Commit SHA
```YAML 
- name: Get short commit SHA
  id: vars
  run: echo "sha_short=$(git rev-parse --short HEAD)" >> "$GITHUB_OUTPUT"
```
-  Gets The short Version of the GIT Commit ID 

Example:
```
a7f32c1
```
Then we can use: 
```
chat-app:sha-a7f32c1
```
2. Log In To Docker Hub 
```YAML 
uses: doceker/login-action@v3
with: 
  username: ${{ secrets.DOCKER_USERNAME }}
  password: ${{ secrets.DOCKER_TOKEN }}
```
- Logs GitHub Actions into our Docker Hub account
- The credentials come from GitHub Secrets, not hardcoded values.

3. Build AND push
```YAML 
push: true
```
- This is the important change.
Previously:
```YAML 
push: false
```
Build only
Now:
```YAML 
push: true
```
- Build + upload to Docker Hub

4. Two image tags
```YAML 
tags: |
  ${{ secrets.DOCKER_USERNAME }}/chat-app:latest
  ${{ secrets.DOCKER_USERNAME }}/chat-app:sha-${{ steps.vars.outputs.sha_short }}
```
we will get: 
```
yourusername/chat-app:latest
yourusername/chat-app:sha-a7f32c1
```
So:
`latest` → points to the latest image.
`sha-a7f32c1` → points to a specific Git commit.

OUTPUT: 
![alt text](image-1.png)

DOCKER HUB OUTPUT: 
![alt text](image-2.png)

Overall flow
```
GitHub push
    ↓
Checkout code
    ↓
Setup Docker
    ↓
Get commit SHA
    ↓
Login Docker Hub
    ↓
Build image
    ↓
Push image 🚀
```

# Task 4: Only Push on Main

This task is about controlling when our Docker image is pushed to Docker Hub.
You want to test that the Docker image can be built successfully on feature branches, but you don't want every developer branch to upload images to Docker Hub.

### Step 1: Update the workflow
```YAML 
name: Docker Build and Push

on:
  push:
    branches:
      - '**'
  pull_request:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Get short commit SHA
        id: vars
        run: echo "sha_short=$(git rev-parse --short HEAD)" >> "$GITHUB_OUTPUT"

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v6
        with:
          context: .
          file: ./Dockerfile
          push: ${{ github.ref == 'refs/heads/main' }}
          tags: |
            ${{ secrets.DOCKER_USERNAME }}/chat-app:latest
            ${{ secrets.DOCKER_USERNAME }}/chat-app:sha-${{ steps.vars.outputs.sha_short }}
```
#### Let's Understand 
1. we changed the trigger
Previously you had:
```YAML 
on:
  push:
    branches: [main]
```
- That means -> Run this workflow only when the code is pushed to `main.`

Now you have:
```YAML 
on:
  push:
    branches:
      - '**'
  pull_request:
    branches:
      - main
```
`push: '**'`
```YAML 
push:
  branches:
    - '**'
```
This Means -> Run this workflow when code is pushed to any branch.


2. You added `pull_request`

```YAML 
pull_request:
  branches:
    - main
```
- This means -> Run the workflow when a Pull Request is made toward `main.`
For example:
```
feature-login
      |
      | Pull Request
      ↓
    main
```
The workflow runs and builds the Docker image.
But it should not push the image.

3. The most important change: `push:`
our Old version was 
```YAML 
push: true 
```
- That means Build the image AND push it to Docker Hub.

Now we have 
```YAML 
push: ${{ github.ref == 'refs/heads/main' }}
```
This is a condition.
GitHub checks:
```
Is the current ref exactly refs/heads/main?
             |
       ┌─────┴─────┐
      YES          NO
       ↓            ↓
   push: true    push: false
```
On `main`
```YAML 
github.ref == 'refs/heads/main'
```
is `true`
Therefore:
```YAML 
push: true
```
- Docker image: BUILD AND PUSH 

On a `feature branch`

For example:
```YAML 
github.ref == 'refs/heads/feature-login'
```
- The condition is false 

Therefore: 
```YAML 
push: fasle
```
Docker image: only BUILD but will Not PUSH 


# Task 5: Add a Status Badge
### Step 1: Get the badge URL

Go to your repo on GitHub → Actions tab → click on the "Docker Build and Push" workflow in the left sidebar (not a specific run — the workflow itself) → click the ... (three-dot menu) in the top right → "Create status badge".

GitHub will show you a Markdown snippet like:
Get the badge URL from the Actions tab

```
[![Docker Build and Push](https://github.com/Anuj2402/github-actions-practice/actions/workflows/docker-build-push.yml/badge.svg)](https://github.com/Anuj2402/github-actions-practice/actions/workflows/docker-build-push.yml)
```

### Step 2: Add it to `README.md`
```bash 
cd ~/github-actions-practice
sed -i '1i [![Docker Build and Push](https://github.com/Anuj2402/github-actions-practice/actions/workflows/docker-build-push.yml/badge.svg)](https://github.com/Anuj2402/github-actions-practice/actions/workflows/docker-build-push.yml)\n' README.md
```
Verify:
```bash 
head -3 README.md
```
Expect the badge Markdown as line 1, a blank line, then our existing README content starting at line 3.
OUTPUT: 
![alt text](image-3.png)

### Step 3: Push and verify green 
```bash 
git add README.md
git commit -m "Add CI status badge to README"
git push origin main
```
Then open:

```
https://github.com/Anuj2402/github-actions-practice
```
OUTPUT: 
![alt text](image-4.png)
- The rendered README on GitHub shows the badge live and green — "passing"

# Task 6: Pull and Run It
Let's actually pull the image we pushed (not just reuse the locally-built one) so this genuinely proves the whole pipeline works end-to-end from Docker Hub.

#### Step 1: Pull the image explicitly
On your Linux machine (or a fresh cloud server if you want a stronger proof — pulling on a machine that never built the image locally is the real test):
```bash 
docker pull anujkumar007/chat-app:sha-aedb3d7
```
Confirm it actually downloaded from the registry, not just used a local cache:
```bash 
docker images anujkumar007/chat-app
```
OUTPUT : 
![alt text](image-5.png)
- Pulled clean from Docker Hub — `Status: Downloaded newer image, 19MB, image ID bb1d515586bc.` Confirmed this came from the registry, not a local build.

#### Step 2: Run it
```bash 
# Network so the app and DB can reach each other by name
docker network create real-app-net 2>/dev/null

# Database
docker run -d --name real-mysql \
  --network real-app-net \
  -e MYSQL_ROOT_PASSWORD=testpass \
  -e MYSQL_DATABASE=chatdb \
  -e MYSQL_USER=chatapp \
  -e MYSQL_PASSWORD=testpass \
  mysql:8.4

sleep 25

# App
docker run -d --name real-chat-app \
  --network real-app-net \
  -p 8080:8080 \
  -e DB_HOST=real-mysql \
  -e DB_PORT=3306 \
  -e DB_USER=chatapp \
  -e DB_PASSWORD=testpass \
  -e DB_NAME=chatdb \
  anujkumar007/chat-app:sha-aedb3d7
```

#### Step 3: Confirm it works

```
docker logs real-chat-app
curl "http://localhost:8080/api/chat-history?from=alice&to=bob"
```
Expect: Chat `server started at http://localhost:8080 `in the logs, {"messages":[]} from curl.

### Notes: The full journey from git push to a running container

## CI/CD Journey: git push → running container

1. **Local development** — code is written/edited in `main.go`, `index.html`,
   `history.html`, `go.mod`, `go.sum`, `Dockerfile` in the local repo clone.

2. **git push origin main** — commits are pushed to the `main` branch on GitHub.

3. **GitHub Actions trigger** — the push event matches the `on: push: branches`
   condition in `.github/workflows/docker-build-push.yml`, which queues a new
   workflow run on a GitHub-hosted `ubuntu-latest` runner.

4. **Checkout code** (`actions/checkout@v4`) — the runner clones the exact
   commit that was just pushed into its own filesystem.

5. **Set up Docker Buildx** (`docker/setup-buildx-action@v3`) — configures
   BuildKit on the runner so the image can be built with modern caching/
   multi-platform support.

6. **Compute short SHA** — a step captures `git rev-parse --short HEAD` so the
   image can be tagged traceably to this exact commit.

7. **Log in to Docker Hub** (`docker/login-action@v3`) — authenticates using
   the `DOCKER_USERNAME` / `DOCKER_TOKEN` repo secrets, never exposing them
   in logs.

8. **Build and push** (`docker/build-push-action@v6`) — runs the multi-stage
   Dockerfile:
     - Stage 1 (`golang:1.22-alpine`): downloads Go modules, compiles a
       static binary (`CGO_ENABLED=0`, stripped symbols).
     - Stage 2 (`alpine:3.20`): copies only the compiled binary + static
       HTML assets, creates a non-root user, sets `USER appuser`.
   The resulting image is tagged (`latest` and `sha-<hash>`) and, since the
   push is on `main`, pushed to Docker Hub.

9. **Docker Hub** — now hosts the new image under both tags, each pointing
   at the same image digest.

10. **Pull anywhere** — `docker pull anujkumar007/chat-app:<tag>` on any
    machine with Docker and internet access retrieves the exact same image
    bytes that were built in CI — no local build step needed.

11. **Run** — `docker run` starts the container. Because the app needs
    MySQL, it's run alongside a `mysql` container on a shared Docker
    network, with connection details passed as environment variables
    (`DB_HOST`, `DB_USER`, etc.) rather than hardcoded.

12. **Confirm it works** — check container logs for a successful startup
    message, hit the REST endpoint with `curl`, and open the app in a
    browser to confirm the WebSocket-based real-time chat functions
    end-to-end.

**Key lesson learned along the way:** a green build/push in CI only proves
the *pipeline* works — it doesn't prove the *content* is correct. Verifying
by digest comparison against a known-good reference, and by actually
exercising the app's real behavior (not just "did it start"), caught two
real bugs that pure CI success would have masked: a stale/wrong source repo,
and an environment-specific frontend bug (ws:// vs wss:// mixed content)
that only local build-and-run testing surfaced.

