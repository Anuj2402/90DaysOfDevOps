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



# Task 2: Dockerfile Instructions

#### Project Structure

```bash 
mkdir dockerfile-demo
cd dockerfile-demo
```
Create the following files:
```
dockerfile-demo/
│
├── Dockerfile
├── app.py
└── requirements.txt
```

### Step 1: Create app.py

```python 
from http.server import HTTPServer, BaseHTTPRequestHandler

class App(BaseHTTPRequestHandler):

    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"Hello from my Docker Container!")

server = HTTPServer(("0.0.0.0", 8000), App)

print("Server started on port 8000")

server.serve_forever()
```
- This creates a very small web server.

### Step 2: Create requirements.txt

- For this example we don't actually need any packages.
Create an empty file.
```
#empty 
```
Later you'll install packages here like:
```
flask
requests
boto3
```
### Step 3: Create the Dockerfile

```dockerfile 
# 1. Base Image
FROM python:3.12-slim

# 2. Metadata
LABEL maintainer="Anuj"

# 3. Working Directory
WORKDIR /app

# 4. Copy dependency file
COPY requirements.txt .

# 5. Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# 6. Copy application
COPY app.py .

# 7. Document the application port
EXPOSE 8000

# 8. Default command
CMD ["python", "app.py"]
```
### Understanding Every Instruction

1. `FROM`

```dockerfile 
FROM python:3.12-slim
```
- Every Dockerfile starts with a base image.

2. `LABEL`

```dockerfile
LABEL maintainer="Anuj"
```
Adds metadata.
Useful for:

- ownership
- version
- project
- maintainer

Example:
```dockerfile 
LABEL project="Inventory API"
LABEL team="DevOps"
LABEL version="1.0"
```
3. `WORKDIR`

```docekerfile 
WORKDIR /app
```
- Creates the directory if it doesn't exist.
- Every following instructions runs from 
```
/app
```
without it you would need 
```dockerfile  
RUN makdir /app
RUN cd /app
```
Docker simplifies this 

4. `COPY`

```dockerfile 
COPY requirements.txt .
```
This will copy From hots machine to container 

COPY Host Machine TO 

↓

Container

Result will be like :

Host Machine
```
requirements.txt
```
↓

Container 
```
/app/requirements.txt
```

5. `RUN`

```dokcerfile 
RUN pip install --no-cache-dir -r requirements.txt
```
- RUNs during build time 

- This installs packages into the image.
- Once buils this command never buils again 

6. COPY Again
```dockerfile 
COPY app.py . 
```
- Copies your application into container /app

7. EXPOSE

```dockerfile 
EXPOSE 8000
```
- This Doesn't actually publish the port 
- It documents that the appplication listen on port :
```
8000
```
To access it from our machine we will still use 
```bash 
docker run -p 8000:8000
```
8. `CMD`
```dockerfile
CMD ["python","app.py"]
```
- This is executed everytime the container starts 
- It launches the application 

### Build the Image
```bash 
docker build -t python-web:v1 . 
```

### Verify Image
```bash 
docker images 
```

OUTPUT: 
![alt text](image-5.png)


### Run the Container

```bash 
docker run -d --name python-container -p 8000:8000 python-web:v1
```
check: 
```bash 
docker ps -a
```
OUTPUT: 
![alt text](image-6.png)

Open Browser: 
visit 

```
http://localhost:8000
```
Output
```
Hello from my Docker Container!

```
OUTPUT: 
![alt text](image-7.png)

Check Logs
```bash 
docker log python-container
```
OUTPUT : 
```
Server started on port 8000
```


### Complete Flow

```
app.py
requirements.txt
Dockerfile
        │
        ▼
docker build
        │
        ▼
Custom Image
        │
        ▼
docker run
        │
        ▼
Running Container
        │
        ├──────────────┐
        ▼              ▼
docker logs      docker exec
        │              │
        ▼              ▼
 Application     Explore Container

 ```





