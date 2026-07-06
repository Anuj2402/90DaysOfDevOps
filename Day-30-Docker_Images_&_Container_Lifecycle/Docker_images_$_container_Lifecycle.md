# Task 1: Docker Images

Docker Images are Read-only templates used to create containers. Think of an image as a blueprint, and a container as the running instance bult from the blueprint.

### Step 1: Pull Images from Docker Hub
Download the required images.

Pull Nginx
```bash 
docer pull nginx
```
Example output:
```
Using default tag: latest
latest: Pulling from library/nginx
Digest: sha256:...
Status: Downloaded newer image for nginx:latest
docker.io/library/nginx:latest
```
OUTPUT: 
![alt text](image.png)



Pull Ubuntu:

```bash 
docker pull ubuntu 
```
OUTPUT: 
![alt text](image-1.png)

Pull Alpine:

```bash 
docker pull alpine 
```
OUTPUT: 
![alt text](image-2.png)

Verify the Downloads:

List the images:

```bash 
docker images 
```
OR 

```bash
docker image ls  
```
OUTPUT: 
![alt text](image-3.png)

- Note: The exact image sizes may vary depending on the image version.

### Step 2: Compare the Image Sizes

| Image  | Approximate Size | Purpose                            |
| ------ | ---------------: | ---------------------------------- |
| Nginx  |           ~66 MB | Web server                         |
| Ubuntu |           ~45 MB | General-purpose Linux distribution |
| Alpine |            ~4 MB | Minimal Linux distribution         |


### Step 3: Why is Alpine Much Smaller?

Ubuntu: 

Ubuntu includes:
- Many system utilities
- Package Manager (`apt`)
- Documantaion
- Locales
- common linux tools 
- Additional libraries

It is designed as a general-purpose operating system.

Alpine: 

Alpine Linux is built specifically to be:
- Small 
- Fast 
- Secure

It includes only the essentials 
- minimal shell 
- BusyBox utilities
- Small C library (`musl`)
- `apk` package manager 

It removes many packages  ubuntu includes by default;

Comparison: 

| Ubuntu                  | Alpine                           |
| ----------------------- | -------------------------------- |
| Full Linux distribution | Minimal Linux distribution       |
| Uses `apt`              | Uses `apk`                       |
| Larger image            | Very small image                 |
| Easier for beginners    | Better for production containers |
| Includes many utilities | Only essential utilities         |

#### Why Use Alpine?

Advantages:

- Faster Downloads 
- Faster deployments
- Less disk usage
- Lower memory footprint
- Smaller attack surface

Disadvantages:
- Fewer built-in tools
- Some applications require extra configuration
- Slightly steeper learning curve

### Step 4: Inspect an Image
Inspect the Nginx image:

```bash 
docker image inspect nginx
```
OR
```bash 
docker inspect nginx
```
- This returns a JSON document with detailed metadata.

```
root@docker-host ~ ➜  docker inspect nginx
[
    {
        "Id": "sha256:ec4ed8b5299e5e90694af7750eb6dffd2627317d30544d056b0371f8082f7bce",
        "RepoTags": [
            "nginx:latest"
        ],
        "RepoDigests": [
            "nginx@sha256:ec4ed8b5299e5e90694af7750eb6dffd2627317d30544d056b0371f8082f7bce"
        ],
        "Comment": "buildkit.dockerfile.v0",
        "Created": "2026-06-24T01:21:58.377973076Z",
        "Config": {
            "ExposedPorts": {
                "80/tcp": {}
            },
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "NGINX_VERSION=1.31.2",
                "NJS_VERSION=0.9.9",
                "NJS_RELEASE=1~trixie",
                "ACME_VERSION=0.4.1",
                "PKG_RELEASE=1~trixie",
                "DYNPKG_RELEASE=1~trixie"
            ],
            "Entrypoint": [
                "/docker-entrypoint.sh"
            ],
            "Cmd": [
                "nginx",
                "-g",
                "daemon off;"
            ],
            "Labels": {
                "maintainer": "NGINX Docker Maintainers <docker-maint@nginx.com>"
            },
            "StopSignal": "SIGQUIT"
        },
        "Architecture": "amd64",
        "Os": "linux",
        "Size": 63132621,
        "RootFS": {
            "Type": "layers",
            "Layers": [
                "sha256:3edb2192497af6e965b9b7e57dc6dbdce1f3ea721d14a98110419d4ded523298",
                "sha256:fcf6aab8bf4a29699bde607fc21ee39e7e1df2884122b053799359a1665eff8a",
                "sha256:2794799fb83d3e03f69652d5c4fc3a854bd5ed9660d1c134204610943884ab97",
                "sha256:f26790bea8ca1115a2a83d2b101a6351e317b3214cd4336e3d68d0410470d618",
                "sha256:24460d3f0d75ae79324ce00c5e066215cbf2e56de3fc6e2ee651ced7746471e0",
                "sha256:35209d7a0ceb10c48d5b3fb1e4c99cd1c6e79e1cdb2d6f9b67f5a9cc65efc308",
                "sha256:e2a57e9f9993940dfc59e79e137eaae9099af5518b57247276dc5e7c58b554a5"
            ]
        },
        "Metadata": {
            "LastTagTime": "2026-07-06T19:10:11.171354662Z"
        },
        "Descriptor": {
            "mediaType": "application/vnd.oci.image.index.v1+json",
            "digest": "sha256:ec4ed8b5299e5e90694af7750eb6dffd2627317d30544d056b0371f8082f7bce",
            "size": 10229
        },
        "Identity": {
            "Pull": [
                {
                    "Repository": "docker.io/library/nginx"
                }
            ]
        }
    }
]

```

Useful Information we Can Find: 

Image ID
```
"Id": "sha256:ec4ed8b5299e5e90694af7750eb6dffd2627317d30544d056b0371f8082f7bce",
```
- A unique identifier for the image.

Creation Date

```
"Created": "2026-06-24T01:21:58.377973076Z",
```
- Shows when the image was built.

Operating System: 

```
 "Os": "linux",
 ```

CPU Architecture: 
```
"Architecture": "amd64",
```
- depending on your machine

Default Command
```bash 
"Cmd": [
                "nginx",
                "-g",
                "daemon off;"
            ],
```
- This is the command that runs when a container starts from the image.

Environment Variables

```
 "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "NGINX_VERSION=1.31.2",
                "NJS_VERSION=0.9.9",
                "NJS_RELEASE=1~trixie",
                "ACME_VERSION=0.4.1",
                "PKG_RELEASE=1~trixie",
                "DYNPKG_RELEASE=1~trixie"
            ],
```

Exposed Ports

```
 "ExposedPorts": {
                "80/tcp": {}
            },
```
- This tells you that the image is configured to expose port 80.

#### Image Layers: 

The image consists of multiple read-only layers.

Each Dockerfile instruction (such as RUN, COPY, or ADD) typically creates a new layer.


#### Step 5: Remove an Image

- Remove an image you no longer need:
```bash 
docker rmi alpine 
```
or 
```bash 
docker image rm alpine 
```
- If the image is still being used by a container, you'll see an error like:
```
Error response from daemon:
conflict: unable to remove repository reference
```
In that case:
- Stop the container.
- Remove the container.
- Remove the image.
Example:
```bash 
docker stop my-container

docker rm my-container

docker rmi alpine

```
Verify the Image Was Removed
```bash 
docker images 
```
- The removed image should no longer appear in the list.

OUTOUT: 
![alt text](image-4.png)


Summary of Commands: 

| Task             | Command                      |
| ---------------- | ---------------------------- |
| Pull Nginx       | `docker pull nginx`          |
| Pull Ubuntu      | `docker pull ubuntu`         |
| Pull Alpine      | `docker pull alpine`         |
| List images      | `docker images`              |
| Inspect an image | `docker image inspect nginx` |
| Remove an image  | `docker rmi alpine`          |


Workflow Diagram

```
Docker Hub
     │
     ▼
docker pull nginx
     │
     ▼
Local Docker Images
     │
     ├───────────────┐
     ▼               ▼
docker images   docker inspect
     │               │
     ▼               ▼
 View images    View metadata
     │
     ▼
docker rmi alpine
     │
     ▼
Image removed
```

#### Q -> Why do many production Docker images use Alpine?

- Alpine provides a much smaller footprint, leading to faster downloads, lower storage and bandwidth usage, reduced memory consumption, and a smaller attack surface, though it may require installing additional packages for some applications
