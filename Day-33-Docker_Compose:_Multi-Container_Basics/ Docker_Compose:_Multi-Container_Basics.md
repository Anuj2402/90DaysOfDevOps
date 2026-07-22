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

