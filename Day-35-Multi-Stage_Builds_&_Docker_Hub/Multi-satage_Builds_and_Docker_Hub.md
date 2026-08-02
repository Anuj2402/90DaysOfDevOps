# Task 1: The Problem with Large Images (Single-Stage Build)

In this Task we will create a simple GO application, Containarize it using a **Single-stage-Dockerzfile** , Build the image and check it's size

Project Structure
```bash 
go-single-stage/
├── Dockerfile
├── go.mod
└── main.go
```
Create the project:
```bash 
mkdir go-single-stage
cd go-single-stage

touch Dockerfile
touch go.mod
touch main.go
```

#### File1: `main.go`
```GO 
package main 

import (
    "fmt"
    "net/http"

)

func home(w http.ResponseWriter , r *http.Request) {

    fmt.Fprintf(w, "Hello from Go running inside Docker!")
}

func main() {
	http.HandleFunc("/", home)

	fmt.Println("Server started on port 8080")

	http.ListenAndServe(":8080", nil)
}

```
This Program : 
- Starts an HTTP server 
- Listens on port 8080
- Returns a simple message when someone visits the root URL.

#### File 2: `go.mod`

```Go
module go-single-stage

go 1.24
```

#### File 3: Dockerfile (Single Stage)

```Dockerfile
# base image 
FROM golang:1.24

WORKDIR /app

COPY go.mod .

COPY main.go . 

RUN go build -0 server . 

EXPOSE 8080

CMD ["./server"]
```

### Understanding the Dockerfile
Base Image
```dockerfile 
FROM golang:1.24
```
Uses the official GO image 

It Contains: 
- Go compiler
- Go SDK
- Linux
- Build tools

Working Directory

```Dockerfile 
WORKDIR /app
```
Creates:
```bash 
/app
```
and makes it the current working directory.

Copy Files

```dockerfile 
COPY go.mod .
COPY main.go .
```
Copies the source code into the image / container.

Build the Binary
```bash 
RUN go buld -o server . 
```

Compiles:
```bash 
main.go 
```
into an executable named: 
```
server 
```
Expose Port

```dockerfile 
EXPOSE 8080
```
Documents that the application listens on port 8080.

Start the Application
```Dockerfile 
CMD ["./server"]
```
Runs the compiled binary when the container starts.


### Step 1: Build the Image
```bash 
docker build -t go-app:vi . 
```
Expected Output: 
```
Successfully built xxxxxxxxx
Successfully tagged go-app:v1
```

Step 2: Check the Image

```bash 
docker images 
```
Example Output:
```bash 
REPOSITORY   TAG   IMAGE ID       SIZE

go-app       v1    a1b2c3d4e5f6   980MB
```

OUTPUT: 

Note: The exact size depends on our Docker version and the Go base image, but it will typically be hundreds of MB to around 1 GB because the image includes the Go compiler and build toolchain.

### Step 3: Run the Container
```bash 
docker run -d -p 8080:8080 --name go-server go-app:v1
```
verify 
```bash 
docker ps 
```
OUTPUT: 


### Step 4: Test the Application

OPEN: 
```
http://localhost:8080
```
Expected output:
```
Hello from Go running inside Docker!
```
OUTPUT: 


Or test with curl:
```bash
curl http://localhost:8080
```
OUTPUT: 


### Step 5: View Logs
```bash 
docker logs go-server
```
OutPut: 


### Step 6: Stop and Remove
```bash 
docker stop go-server
docker rm go-server
```
#### Project Flow
```
main.go
     │
     ▼
Dockerfile
     │
     ▼
docker build
     │
     ▼
Go Compiler
     │
     ▼
Creates Binary (server)
     │
     ▼
Docker Image
     │
     ▼
docker run
     │
     ▼
Go HTTP Server
     │
     ▼
http://localhost:8080
```

#### Commands Summary

| Task             | Command                                                 |
| ---------------- | ------------------------------------------------------- |
| Build image      | `docker build -t go-app:v1 .`                           |
| List images      | `docker images`                                         |
| Run container    | `docker run -d -p 8080:8080 --name go-server go-app:v1` |
| View logs        | `docker logs go-server`                                 |
| Test app         | `curl http://localhost:8080`                            |
| Stop container   | `docker stop go-server`                                 |
| Remove container | `docker rm go-server`                                   |


#### What to Note
Record the image size from 
```bash 
docker image 
```
OUTPUT: 


- we'll compare this with a multi-stage Docker build in the next task. The multi-stage image will be dramatically smaller because it contains only the compiled binary and runtime essentials, not the Go compiler and build tools.

### IMP Q: Why is a single-stage Go Docker image so large?

A single-stage build uses the full Go base image for both compiling and running the application. As a result, the final image includes the Go compiler, SDK, package cache, and other build tools that are no longer needed at runtime. This increases the image size significantly. Multi-stage builds solve this by compiling the application in one stage and copying only the final binary into a minimal runtime image.