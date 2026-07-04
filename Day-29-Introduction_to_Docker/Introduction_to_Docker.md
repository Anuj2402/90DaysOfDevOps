# Task 1: What is Docker?

### Q1 -> What is a Container and Why Do We Need Them?
A container is a lightweight, standalone package that contains everything an application needs to run:

- Application code 
- Runtime 
- System libraries 
- Dependencies
- Configuration files

Containers share the host operarting system's kernal , making them much lighter than virtual machines.

### Why do we need containers?

Before containers, developers often faced the "It works on my machine" problem because applications behaved differently across environments.

Containers solve this by:

- Providing the same environment everywhere (development, testing, production)
- Eliminating dependency conflicts
- Starting in seconds
- Using fewer system resources
- Making deployment faster and more reliable
- Scaling applications easily

Example:

- Imagine developing a Python application on your laptop. Instead of asking others to install Python, libraries, and dependencies manually, you package everything into a Docker container. Anyone with Docker can run it with a single command.

### Q2 -> 2. Containers vs Virtual Machines

```
| Feature        | Containers           | Virtual Machines       |
| -------------- | -------------------- | ---------------------- |
| OS             | Share host OS kernel | Each VM has its own OS |

| Size           | MBs                  | GBs                    |

| Startup Time   | Seconds              | Minutes                |

| Performance    | Near native          | Slight overhead        |

| Resource Usage | Low                  | High                   |

| Isolation      | Process-level        | Hardware-level         |

| Portability    | Very High            | Moderate               |

```

```text 
1. Resource Utilization: Containers share the host operating system kernel, making them lighter and faster than VMs. VMs have a full-fledged OS and hypervisor, making them more resource-intensive.

2. Portability: Containers are designed to be portable and can run on any system with a compatible host operating system. VMs are less portable as they need a compatible hypervisor to run.

3. Security: VMs provide a higher level of security as each VM has its own operating system and can be isolated from the host and other VMs. Containers provide less isolation, as they share the host operating system.

```

![alt text](image.png)

- Containers share the same operating system kernel, making them lightweight and fast.
- Each VM has its own operating system, consuming more CPU, RAM, and storage.

### Q3-> Docker Architecture

Docker follows a client-server architecture.

It consists of five main components:

i. Docker Client

- The Docker Client is the command-line interface (CLI) that users interact with.

Example commands:
```bash 
docker run ngnix 
docker build . 
docker pull ubuntu 
```
- The client sends request to Docker Daemon 

ii. Docker Daemon (`dockerd`)

The Docker Daemon is the background service responsible for:

- Building images
- Running containers
- Managing networks
- Managing volumes
- Communicating with registries

It listens for Docker API requests from the client.

iii. Docker Images

A Docker Image is a read-only template used to create containers.

- Think of an image like a blueprint or recipe.

Examples:

- Ubuntu image
- Nginx image
- Python image

Images contain:

- Base operating system
- Application
- Dependencies
- Libraries

Images are immutable (they don't change after creation).

iv. Docker Containers

A container is a running instance of an image.

Example:

```
Image
   ↓
docker run
   ↓
Container
```
- One image can create many containers.

Example:

```
Ubuntu Image
     ↓
------------------------
Container 1
Container 2
Container 3
```

v. Docker Registry

A registry stores Docker images.

The default public registry is Docker Hub

You can:
```
Pull images
Push your own images
Store private images
```

Examples:
```
Docker Hub
Private Registry
Cloud registries (such as those provided by major cloud platforms)
```

### Q4 -> Docker Architecture (In My Own Words)

Imagine Docker as an online food delivery system.

```
                USER
                  |
          docker run nginx
                  |
                  ▼
          Docker Client (CLI)
                  |
          Sends API Request
                  |
                  ▼
        Docker Daemon (dockerd)
                  |
      -------------------------
      |           |           |
      ▼           ▼           ▼
  Docker      Docker      Docker
  Images    Containers   Networks
                  |
                  ▼
          Pull image if missing
                  |
                  ▼
         Docker Registry (Docker Hub)

```

Explanation:

1. The user types a command like:

```bash 
docker run ngnix 
```
2. The Docker Client sends this request to the Docker Daemon.
3. The Docker Daemon checks whether the Nginx image exists locally.
4. If the image isn't available, the daemon downloads it from the Docker Registry (Docker Hub).
5. The daemon creates a container from the image.
6. The application starts running inside the container



# Task 2: Install Docker

### Step 1: Install Docker Desktop

-  Go to the official Docker website.
- Download Docker Desktop for Mac (choose the version for your Mac: Apple Silicon or Intel).
- Install it by dragging Docker.app into the Applications folder.
- Launch Docker Desktop.
- Wait until Docker starts. You'll see the whale icon in the menu bar and a message like:

```text 
Docker Desktop is running
```

### Step 2: Verify the Installation
Open Terminal and run:
```bash 
docker --version
```

Example output:
```bash 
anujrai@anujrai-mn4561 90DaysOfDevOps % docker --version 
Docker version 29.2.1, build a5c7197
anujrai@anujrai-mn4561 90DaysOfDevOps % 
```

Now check whether Docker is running:
```bash 
docker info 
```
Output: 
```
Client
Server
Containers
Images
Storage Driver
CPUs
Memory

Client:
 Version:    29.2.1
 Context:    desktop-linux
 Debug Mode: false
 Plugins:
  agent: create or run AI agents (Docker Inc.)
    Version:  v1.27.1
    Path:     /Users/anujrai/.docker/cli-plugins/docker-agent


Server:
 Containers: 8
  Running: 5
  Paused: 0
  Stopped: 3
 Images: 11
 Server Version: 29.2.1
 Storage Driver: overlayfs
  driver-type: io.containerd.snapshotter.v1
 Logging Driver: json-file
 Cgroup Driver: cgroupfs
 Cgroup Version: 2
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local splunk syslog
 CDI spec directories:
  /etc/cdi
  /var/run/cdi
 Discovered Devices:
  cdi: docker.com/gpu=webgpu
 Swarm: inactive
 Runtimes: io.containerd.runc.v2 runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: dea7da592f5d1d2b7755e3a161be07f43fad8f75
 runc version: v1.3.4-0-gd6d73eb8
 init version: de40ad0
 Security Options:
  seccomp
   Profile: builtin
  cgroupns
 Kernel Version: 6.12.72-linuxkit
 Operating System: Docker Desktop
 OSType: linux
 Architecture: aarch64
 CPUs: 12
 Total Memory: 7.652GiB
 Name: docker-desktop
 ID: 442fccd1-683e-4f3e-a921-c3453db7153b
 Docker Root Dir: /var/lib/docker
 Debug Mode: false
 HTTP Proxy: http.docker.internal:3128
 HTTPS Proxy: http.docker.internal:3128
 No Proxy: hubproxy.docker.internal
 Labels:
  com.docker.desktop.address=unix:///Users/anujrai/Library/Containers/com.docker.docker/Data/docker-cli.sock
 Experimental: false
 Insecure Registries:
  hubproxy.docker.internal:5555
  ::1/128
  127.0.0.0/8
 Live Restore Enabled: false
 Firewall Backend: iptables

````



### Step 3: Run Your First Container

Run:

```bash 
docker run hello-world
```
- The first time, Docker downloads the image because it isn't available locally.

Example output:
```
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
Status: Downloaded newer image for hello-world:latest
...
Hello from Docker!
This message shows that your installation appears to be working correctly.
...
```

### Step 4: Understand What Happened

When we executed:

```bash 
docker run hello-world 
```
Docker performed these steps:

i. Docker Client Received the Command
```bash 
docker run hello-world 
```
- The Docker Client sent this request to the Docker Daemon.

ii. Docker Daemon Looked for the Image

- Docker checked whether the hello-world image already existed on your computer.

- Since this was your first run, the image wasn't found.

iii. Docker Pulled the Image
- Docker automatically downloaded the hello-world image from Docker Hub, the default Docker registry.

iv. Docker Created a Container
- After downloading the image, Docker created a new container from it.

Think of it like this:
```
Image
   ↓
docker run
   ↓
Container
```

v. The Container Executed

The hello-world program inside the container printed the message:
```
Hello from Docker!
```
This confirms that Docker is working correctly.

vi. The Container Stopped
- The hello-world application completed its task and exited.

- Since the container had nothing else to do, it stopped automatically.

### Step 5: Verify the Container

Run: 
```bash 
docker ps -a 
```

```
anujrai@anujrai-mn4561 90DaysOfDevOps % docker ps -a
CONTAINER ID   IMAGE                       COMMAND                  CREATED          STATUS                      PORTS                                 NAMES
f6d4f939f30e   hello-world                 "/hello"                 17 seconds ago   Exited (0) 16 seconds ago                 
```
Exited (0) means:
- The program completed successfully.
- No errors occurred.


### Step 6: Check Downloaded Images

List local images:
```bash 
docker images 
```

Example output:
```
REPOSITORY    TAG       IMAGE ID
hello-world   latest    abc12345
```

![alt text](<Screenshot 2026-07-03 at 12.06.21 AM.png>)

- This confirms the image has been downloaded and stored locally.


## Flow of What Happened

```
You type:
docker run hello-world
        │
        ▼
Docker Client
        │
        ▼
Docker Daemon
        │
        ▼
Checks for image locally
        │
        ├── Found? → Create container
        │
        └── Not found
                │
                ▼
        Download image from Docker Hub
                │
                ▼
        Create container
                │
                ▼
        Run application
                │
                ▼
        Print "Hello from Docker!"
                │
                ▼
        Container exits
   
```


# Task 3: Run Real Containers

### 1. Run an Nginx Container

Start an Nginx container:
```bash 
docker run -d --name my-nginx -p 8080:80 nginx
```
What each option means

| Option            | Meaning                                                       |
| ----------------- | ------------------------------------------------------------- |
| `docker run`      | Create and start a container                                  |
| `-d`              | Run in detached (background) mode                             |
| `--name my-nginx` | Give the container a custom name                              |
| `-p 8080:80`      | Map port 8080 on your machine to port 80 inside the container |
| `nginx`           | Docker image to use                                           |

Verify It's Running
```bash
docker ps 
```
Example output:

```
CONTAINER ID   IMAGE    STATUS         PORTS
abc12345       nginx    Up 2 minutes   0.0.0.0:8080->80/tcp
```

Access Nginx in Your Browser

Open:
```
http://localhost:8080
```
- You should see the default Welcome to nginx! page.

This confirms:
- Docker container is running.
- Port mapping works.
- Nginx is serving web pages.


### 2.Run an Ubuntu Container in Interactive Mode
Start Ubuntu:

```bash
docke run -it --name my-ubuntu ubuntu 
```
Docker may first download the Ubuntu image if it isn't already available.

The prompt changes to something like:
```
root@4d8c7e:/#
```
OUTPUT:
![alt text](image-1.png)

- You're now inside the Ubuntu container.

Explore the Ubuntu Container
Try these commands:
```bash 
pwd
ls 
whoami 
hostname
cat /etc/os-release
uname -a
ps

```
OUTPUT 
![alt text](image-2.png)


Exit the Container
```
exit
```
- The container stops after you exit because its main process has ended.

### 3. List Running Containers

### 4. List All Containers

```bash 
docker ps # This shows only containers that are currently running. 
   OR
docker ps -a # This includes both running and stopped containers.
```
Example:
```
CONTAINER ID   IMAGE   STATUS
abc123         nginx   Up 5 minutes
```
OUTPUT: 
![alt text](image-3.png)

- This shows only containers that are currently running. 

### 5. Stop a Container

Stop the ubuntu container:
```bash 
docker stop ubuntu 
```
Verify:
```bash 
docker ps 
```
- The Ubuntu container should no longer appear because it's stopped.


### 6. Remove a Container

Remove the stopped/exited ubuntu container:

```bash 
docker rm my-ubuntu
    OR 
docker rm 553ae9471116
```
Verify:
```bash 
docker ps -a
```
OUTPUT: 
![alt text](image-4.png)


- The removed containers will no longer be listed


How It Works
```
docker run
      │
      ▼
Docker checks if the image exists locally
      │
      ├── Yes → Use local image
      └── No  → Download image from Docker Hub
                    │
                    ▼
             Create a new container
                    │
                    ▼
              Start the container
                    │
                    ▼
         Application runs inside it

```
