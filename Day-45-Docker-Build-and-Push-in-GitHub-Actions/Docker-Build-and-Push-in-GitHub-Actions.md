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

