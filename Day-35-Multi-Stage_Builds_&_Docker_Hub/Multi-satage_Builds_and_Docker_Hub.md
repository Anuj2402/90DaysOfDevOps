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
![alt text](image.png)

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
![alt text](image-1.png)


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
### Step 5: View Logs
```bash 
docker logs go-server
```
OutPut: 
![alt text](image-2.png)

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
![alt text](image.png)

- we'll compare this with a multi-stage Docker build in the next task. The multi-stage image will be dramatically smaller because it contains only the compiled binary and runtime essentials, not the Go compiler and build tools.

### IMP Q: Why is a single-stage Go Docker image so large?

A single-stage build uses the full Go base image for both compiling and running the application. As a result, the final image includes the Go compiler, SDK, package cache, and other build tools that are no longer needed at runtime. This increases the image size significantly. Multi-stage builds solve this by compiling the application in one stage and copying only the final binary into a minimal runtime image.

# Task 2: Multi-Stage Build

In this Task we will rewrite the previous Dockerfile using a **multi-stage build** . This is the standard approach used in production because it keeps the final image small by excluding the GO compiler and build tools. 

we will use: 
- **Stage 1:** Build the Go application.
- **Stage 2:** Copy only the compiled binary into a minimal Alpine image.

### Project Structure
Use the same project from Task 1.
```
go-multi-stage/
├── Dockerfile
├── go.mod
└── main.go
```
- Only the Dockerfile changes. 

### File 1: `main.go`
(No changes)

```GO 
package main

import (
	"fmt"
	"net/http"
)

func home(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello from Go running inside Docker!")
}

func main() {
	http.HandleFunc("/", home)

	fmt.Println("Server started on port 8080")

	http.ListenAndServe(":8080", nil)
}
```
### File 2: `go.mod`
(No changes)
```GO 
module go-single-stage

go 1.24
```
### File 3: `Dockerfile (Multi-Stage)`

```dockerfile
# ============================
# Stage 1 - Build the Go App
# ============================

FROM golang:1.24 AS builder

WORKDIR /app

COPY go.mod .

COPY main.go .

RUN CGO_ENABLED=0 GOOS=linux go build -o server .

# ============================
# Stage 2 - Runtime Image
# ============================

FROM alpine:3.22

WORKDIR /app

COPY --from=builder /app/server .

EXPOSE 8080

CMD ["./server"]

```

### Understanding the Dockerfile

Stage 1
```dockerfile 
FROM golang:1.24 AS builder
```
Creates a temporary image named:
```
builder 
```
This stage contains:
- Go Compiler
- Go SDK
- Build tools
- Linux
Used only for compilation.

Working Directory
```dockerfile 
WORKDIR /app
```
Creates:
```
/app
```
Copy Source Files
```bash 
COPY go.mod .

COPY main.go .
```
Copies the application source code.

Compile

```dockerfile 
RUN go build -o server .
```

Produces:
```
/app/server
```
This is the compiled Go binary.

Stage 2

Now Docker starts from a completely new image.

```dockerfile 
FROM alpine:3.22
```
Instead of using the large Go SDK image,

we use Alpine Linux.

Alpine is only around 7–10 MB.


Working Directory
```dockerfile 
WORKDIR /app
```
Creates:
```
/app
```

Copy Only the Binary
```dockerfile 
COPY --from=builder /app/server .
```
This is the important line.

Docker copies only:
```
server
```
from the first stage.

It does not copy:

- Go compiler
- SDK
- Cache
- Source code
- Build tools

Only the executable.

Expose

```dockerfile
EXPOSE 8080
```
Documents the application port.

Start Application
```dockerfile 
CMD ["./server"]
```
Runs the compiled binary.

### Step 1: Build the Image

```bash 
docker build -t go-app:v2 .
```
Expected output:
```
Successfully built xxxxxxxxx

Successfully tagged go-app:v2
```
### Step 2: Compare Image Sizes

```bash 
docker images 
```

Output:
![alt text](image-3.png)

- our exact numbers will vary depending on the Go and Alpine versions, but the multi-stage image should be dramatically smaller than the single-stage image.

### Step 3: Run the Container

```bash 
docker run -d -p 8080:8080 --name go-server-v2 go-app:v2
```
Verify:
```bash 
docker ps 
```

Output: 
![alt text](image-4.png)


### Step 4: Test the Application

Open:
```
http://localhost:8080

OR 

curl http://localhost:8080

```
Output: 
![alt text](image-5.png)

### Step 5: View Logs
```bash 
docker logs go-server-v2
```

Output:
![alt text](image-6.png)

```
Server started on port 8080
```

### Step 6: Stop and Remove
```bash 
docker stop go-server-v2

docker rm go-server-v2
```

### How Multi-Stage Build Works
```
               Stage 1
      ┌─────────────────────────┐
      │ golang:1.24             │
      │                         │
      │ Copy Source             │
      │ Compile                 │
      │                         │
      │ server                  │
      └──────────┬──────────────┘
                 │
                 │ COPY --from=builder
                 ▼
      ┌─────────────────────────┐
      │ alpine:3.22             │
      │                         │
      │ server                  │
      │                         │
      │ CMD ./server            │
      └─────────────────────────┘

```
Only the compiled binary moves into the second stage.

Everything else is discarded.

### Image Size Comparison

| Build Type   | Base Image    | Approximate Size |
| ------------ | ------------- | ---------------: |
| Single-stage | `golang:1.24` |     ~900 MB–1 GB |
| Multi-stage  | `alpine:3.22` |        ~10–20 MB |

The exact sizes depend on your environment, but the reduction is usually more than 95%.

### Notes

#### Why is the multi-stage image so much smaller?
The first stage contains everything required to build the application, including the Go compiler, SDK, package cache, source code, and other build tools. These are only needed during compilation.

The second stage starts from a minimal runtime image (`alpine`) and copies only the compiled executable from the builder stage. Because the compiler, source files, caches, and build dependencies are left behind, the final image is much smaller. Smaller images download faster, start more quickly, consume less storage, and reduce the attack surface by including fewer unnecessary components.

### Imp : Q: What are the advantages of a multi-stage Docker build?
Multi-stage builds separate the build environment from the runtime environment. The application is compiled in a builder image that contains the required SDK and tools, and only the final executable is copied into a minimal runtime image. This results in significantly smaller images, faster deployments, improved security through a reduced attack surface, and cleaner production containers without build-time dependencies.