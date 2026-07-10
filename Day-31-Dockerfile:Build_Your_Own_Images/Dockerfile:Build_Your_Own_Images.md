# Task 1: Your First Dockerfile

### Step 1: Create a Project Directory

Create a new Folder 

```bash 
mkdir my-first-image
```

Move into it : 
```bash 
cd my-first-image
```
Verify your location 
```bash 
pwd 
```
OUTPUT: 
![alt text](image.png)

### Step 2: Create a Dockerfile
Create a file name Dockerfile By vi into it 
```bash 
vi Dockerfile # it will create a file name called Dockerfile and vi into it 
```

### Step 3: Add the Following Content
```dockerfile
# use ubuntu as a base image 
FROM ubuntu:latest

#update the package list and install curl 
RUN apt-get update && apt-get install -y curl 

#Default Command 
CMD ["echo" , "Hello from my custom image!"]

```

### Understanding Each Instruction

`FROM`
```dockerfile 
FROM ubuntu:latest
```
- specifies the base image 
- Every Dockerfile starts with a `FROM` image
- Here , we are using the latest Ubuntu image.


`RUN`


```dockerfile 
RUN apt-get update && apt-get install -y curl 
```
- Executes the Command while buikding the image 
- Updates package metadata 
- Installs the curl package 
- The `-y` option automatically ans   `yes` to installation prompts. 

`CMD`

```dockerfile 
CMD ["echo", "Hello from my custom image!"]
```
- Defines the defaults command executed when a container starts. 
- When the container runs, it prints : 

```
Hello from my custom image!
```
### Step 4: Verify the Dockerfile

```bash 
cat Dockerfile 
```
OUTPUT:
![alt text](image-1.png)

### Step 5: Build the Image

```bash 
docker build -t my-ubuntu:v1 . 
```
What does this command mean?

| Part           | Meaning                                        |
| -------------- | ---------------------------------------------- |
| `docker build` | Build an image                                 |
| `-t`           | Assign a tag                                   |
| `my-ubuntu:v1` | Image name and version                         |
| `.`            | Use the current directory as the build context |

OUTPUT: 
![alt text](image-2.png)

### Step 6: Verify the Image

List all images:
```bash 
docker images 
```
OUTPUT: 
![alt text](image-3.png)

### Step 7: Run the Container

Run your image:
```bash 
docker run my-ubuntu:v1
```
Expected output:

```bash
Hello from my custom image!
```
- After printing the message, the container exits because the echo command has finished.

### Step 8: Verify the Container
```bash 
docker ps -a 
```
OUTPUT: 
![alt text](image-4.png)

Build Workflow
```
Dockerfile
     │
     ▼
docker build -t my-ubuntu:v1 .
     │
     ▼
Custom Docker Image
     │
     ▼
docker run my-ubuntu:v1
     │
     ▼
Hello from my custom image!

```
Commands Used

| Task              | Command                          |
| ----------------- | -------------------------------- |
| Create directory  | `mkdir my-first-image`           |
| Enter directory   | `cd my-first-image`              |
| Create Dockerfile | `touch Dockerfile`               |
| Build image       | `docker build -t my-ubuntu:v1 .` |
| List images       | `docker images`                  |
| Run image         | `docker run my-ubuntu:v1`        |
| List containers   | `docker ps -a`                   |


### IMPT Q-> Q: What is the difference between RUN and CMD in a Dockerfile?

- `RUN` executes commands during the image build process and creates a new image layer (e.g., installing packages like curl).

- `CMD` specifies the default command that runs when a container starts from the image. It does not execute during the build and can be overridden when you run the container.


