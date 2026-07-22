# Task 1: Install & Verify Docker Compose

Docker Compose is a tool for defining and managing multi-container Docker applications using a YAML file ( `docker-compose.yml` or `compose.yaml`).

Modern Docker Desktop includes Docker Compose by default as the Compose V2 plugin, so you usually don't need to install it separately.

### Step 1: Check if Docker Compose is Installed

Run: 
```bash 
docker compose version 
```
Note: Modern Docker uses `docker compose` (with a space), not the older `docker-compose` command.

Expected Output
```
Docker Compose version v5.0.2
```
- If you see a version similar to the above, Docker Compose is installed and ready to use.

### Step 2: Verify Docker is Running

Check the Docker Engine:
```bash 
docker version
```
Example:
```bash 
Client:
 Version:           28.x.x

Server:
 Engine:
  Version:          28.x.x

```
Example:

```
Client:
 Version:           28.x.x

Server:
 Engine:
  Version:          28.x.x

```
Both Client and Server sections should appear. If only the client appears, make sure the Docker daemon (or Docker Desktop) is running.

### Step 3: Verify Docker Compose Works

Run: 
```bash 
docker compose 
```
we can see the compose help menu , for example: 
```
Usage: docker compose [OPTIONS] COMMAND

Commands:
  up
  down
  build
  ps
  logs
  exec
  pull
  restart
  stop
  ...
```

This confirms the Compose plugin is working correctly.

Commands Summary

| Task                            | Command                    |
| ------------------------------- | -------------------------- |
| Check Compose version           | `docker compose version`   |
| Check Docker version            | `docker version`           |
| Verify Compose is working       | `docker compose`           |
| (Optional) Check legacy Compose | `docker-compose --version` |

## Q: What is Docker Compose?

Docker Compose is a tool for defining and running multi-container Docker applications. It uses a YAML configuration file to describe services, networks, volumes, environment variables, and port mappings. With a single command such as docker compose up, you can build and start an entire application stack consistently across development and testing environments.

# Task 2: Your First Docker Compose File

In this task we will create our first Docker Compose project that runs a single nginx
container 

Instead of typing a long `docker run` command, we'll define everything in a `docker-compose.yml` file and let Docker Compose manage the container


##### Project Structure: -> Create a new project directory:


```bash 
mkdir compose-basics
cd compose-basics
```
our project should look like:
```
compose-basics/
└── docker-compose.yml
```

### Step 1: Create docker-compose.yml

Create the file:
```bash 
vi docker-compose.yml
```
```YAML
services:
  nginx:
    image: nginx:alpine
    container_name: nginx-compose
    ports:
      - "8080:80"
```

#### Understanding the Compose File

`services`

- Defines the containers that Docker Compose will create.

`nginx`

 The service name.

 Docker Compose uses this name for:
 - Service discovery
 - DNS resolution
 - Managing the container

`image`

```
image: nginx:alpine
```
- Tells Docker which image to use.

- If the image doesn't exist locally, Docker automatically downloads it.

`container_name`

```YAML
container_name: nginx-compose
```
- Assigns a custom name to the container.

- Without this, Docker Compose generates a name automatically.

`ports`

```YAML
ports:
  - "8080:80"
```
Maps:
```
Host Port      Container Port
8080     --->        80
```
we will access Nginx using:
```
http://localhost:8080
```

### Step 2: Start the Application

Run: 
```bash 
docker compose up 
```
Example output:
```
[+] Running 1/1
 ✔ Container nginx-compose Started
 ```
 - The terminal stays attached and displays container logs.

 ### Step 3: Run in Detached Mode (Optional)

 To run in the background:
 ```bash 
 docker compose up -d
 ```
 Verify:
 ```bash 
 docker ps 
 ```
 Example:
 ```bash 
 CONTAINER ID   IMAGE           STATUS
ab123456       nginx:alpine    Up 10 seconds
```

### Step 4: Access the Website

Open your browser:
```
http://localhost:8080
```
we can  should see the default Welcome to nginx! page.

### Step 5: View Running Services
```bash
docker compose ps 
```
Example:
```
NAME             IMAGE           STATE
nginx-compose    nginx:alpine    running
```

### Step 6: View Logs
```bash 
docker compose logs
```
Or follow logs in real time:
```bash 
docker compose logs -f
```

### Step 7: Stop the Application

If running in the foreground:
```bash 
ctrl + c 
```
If running in detached mode:
```
docker compose down
```
Example output:
```
[+] Running 1/1
 ✔ Container nginx-compose Removed
 ✔ Network compose-basics_default Removed
 ```
 OUTPUT: 
 ![alt text](image.png)
 
- Notice that Docker Compose also removes the automatically created network.

### Complete Workflow

```
docker-compose.yml
        │
        ▼
docker compose up
        │
        ▼
Nginx Container
        │
        ▼
http://localhost:8080
        │
        ▼
docker compose down
        │
        ▼
Container Removed
Network Removed
```
### Commands Summary

| Task                      | Command                                     |
| ------------------------- | ------------------------------------------- |
| Create project            | `mkdir compose-basics && cd compose-basics` |
| Create Compose file       | `touch docker-compose.yml`                  |
| Start application         | `docker compose up`                         |
| Start in background       | `docker compose up -d`                      |
| View running services     | `docker compose ps`                         |
| View logs                 | `docker compose logs`                       |
| Follow logs               | `docker compose logs -f`                    |
| Stop and remove resources | `docker compose down`                       |


## Q: What are the advantages of using Docker Compose instead of `docker run`?

Docker Compose allows you to define your application's infrastructure as code using a YAML file. Instead of remembering long docker run commands, you can describe containers, networks, volumes, environment variables, and dependencies in a single file. This makes applications easier to deploy, share, version-control, and reproduce across development, testing, and production environments.



