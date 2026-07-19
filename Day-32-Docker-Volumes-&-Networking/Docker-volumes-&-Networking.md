# Task 1: The Problem – Understanding Data Persistence in Docker

In this task we will observe that what happens to data stored inside a Docker container when the container is removed 

### Step 1: Run a PostgreSQL Container

pull the postgreSQL image (if we don't already have it )
```bash 
docker pull postgres
```
Run a PostgreSQL container:
```bash 
docker run -d  --name postgres-db  -e POSTGRES_PASSWORD=admin123  -p 5432:5432 postgres

```
Verify the container is running:
```bash 
docker ps 
   OR 
docker ps -a 
```
OUTPUT: 


### Step 2: Connect to PostgreSQL

Open a shell inside the container:
```bash 
docker exec -it postgres-db psql -U postgres 
```
we should see the postgreSQL prompt: 

```
postgres=# 
```
### Step 3: Create a Table
Create a sample Table :

```
CREATE TABLE employees (
    id SERIAL PRIMARY KEY , 
    name VARCHAR(50), 
    role VARCHAR(50)
);

# Insert a few records:

INSERT INTO employees(name , role )
VALUES 
('Anuj' 'Devops Engineer),
('Rahul' , 'SRE'),
('Priya' , 'Cloud Engineer');

# Verify the data:

SELECT * FROM employees; 

```

Example output:

![alt text](image.png)


```
/q # exit postgresSQL 
```

### Step 4: Stop the Container

```bash 
docker stop postgres-db
```

### Step 5: Remove the Container

```bash 
docker rm postgres-db 
```

Verify:
```bash 
docker ps -a 
```
![alt text](image-1.png)
- The container no longer exists.


### Step 6: Run a New PostgreSQL Container

```bash
docker run -d --name postgres-db -e POSTGRES_PASSWORD=admin123 -p 5432:5432 postgres
```

Connect again:
```bash 
dockre exec -it postgres-db psql -U postgres
```

List the tables:
```
/dt 
```

OUTPUT: 
![alt text](image-2.png)

### What Happened?

When we remove the original container , all the data stored inside its writable layer was also deleted . 

The new PostgreSQL container starts with a fresh filesystem created from the original image . Since no persistent storage was attached, the database files from the previous container were lost.

This demonstrates that containers are **ephemeral**. Their writable layer exists only for the lifetime of the container. Removing the container removes any data stored inside it unless that data is kept in a Docker volume or a bind mount.

### Why Did This Happen?

Docker images are read-only. When a container starts, Docker adds a writable layer on top of the image. Any files created or modified inside the container are stored in this writable layer.

When the container is removed:
- The writable layer is deleted.
- All application data stored inside the container is lost.
- A new container starts with a clean writable layer.
- This is why databases such as PostgreSQL, MySQL, MongoDB, and Redis should always use persistent storage in production.


#### Q: Why is database data lost when a Docker container is removed?

Answer:

Because a container stores changes in its writable layer. When the container is deleted, that writable layer is also deleted. Without a Docker Volume or Bind Mount, the database files are not persisted, so a new container starts with an empty database.

# Task 2: Named Volumes

In this task we will learn how Docker Named volumes solve the data persistance problem that we faced in the TASK-01 

Ulike a container's writable layer , a named volumes exists independently of the container , so our data remain safe even if the container is deleted 


### Step 1: Create a Named Volume

Create a Docker volume:

```bash 
docker volume create postgres-data
```
Verify that the volume exist 
```bash 
docker volume ls 
```

OUTPUT: 
![alt text](image-3.png)

### Step 2: Run PostgreSQL with the Volume

Now we will Run PostgreSQL container and attached the volumes 
```bash 
docker run -d --name postgres-db -e POSTGRES_PASSWORD=admin123 -v postgres-data:/var/lib/postgresql -p 5432:5432 postgres:18
```
Understanding `-v` : 
```
postgres-data:/var/lib/postgresql/data
```
| Part                       | Meaning                                        |
| -------------------------- | ---------------------------------------------- |
| `postgres-data`            | Docker named volume (present in local )                           |
| `/var/lib/postgresql/data` | PostgreSQL data directory inside the container |

- All the databse files will now be stored in the Docker volume instead of the container's writable layer 

### Step 3: Connect to PostgreSQL

```bash 
docker ecec -it postgres-db psql -U postgres
```

#### Step 4: Create a Table

```sql
CREATE TABLE employees  (
    id SERIAL PRIMARY KEY, 
    name VARCHAR(50), 
    role VARCHAR(50)
);

-- Insert data:

INSERT INTO employees (name, role )
VALUES
('Anuj' , 'DevOps Engineer')
('Rahul','SRE')
('Priya','Cloud Engineer')


-- Verify 
SELECT * FROM employees;

-- To exit the postgres Database 

\q

```

OUTPUT: 
![alt text](image-4.png)

### Step 5: Stop and remove  the Container
```bash 
docekr stop postgres-db && docker rm postgres-db
```

- We notice that only the **container is removed** . The volume is still exists 

### Step 6: Verify the Volume
```bash 
docker volume ls 
```
Output:
```
DRIVER    VOLUME NAME
local     postgres-data
```
- The volume is still available.

### Step 8: Run a Brand New Container
Start another PostgreSQL container using the same volume:

```bash 
docker run -d --name postgres-db -e POSTGRES_PASSWORD=admin123 -v postgres-data:/var/lib/postgresql -p 5432:5432 postgres:18

```
OUTPUT : 
![alt text](image-5.png)
![alt text](image-6.png)

- The table is still there 
- Data also preserved 

### Step 9: Inspect the Volume

Inpect the volume which we have created and mounted to the container 
```bash 
docker volume inspect postgres-data
```
OUTPUT: 
```JSON
root@docker-host ~ ➜  docker inspect postgres-data



[
    {
        "CreatedAt": "2026-07-18T08:43:48-04:00",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/postgres-data/_data",
        "Name": "postgres-data",
        "Options": null,
        "Scope": "local"
    }
]


```
Architecture

```

               Docker Volume
          postgres-data
                 │
                 │
      -----------------------
      │                     │
      ▼                     ▼
Container 1           Container 2
(Postgres)            (New Postgres)
      │                     │
      └──────────► Same Data
```


## What Happened?

Unlike the previous task, the database files were not stored inside the container. They were stored in the Docker named volume.

When the first container was removed:


- The container was deleted.
- The Docker volume remained.
- The database files remained inside the volume.

When a new container was started using the same volume, PostgreSQL automatically used the existing database files, so the table and data were still available.

### Why Named Volumes Are Important:

Named volumes are commonly used for stateful applications such as:

- PostgreSQL
- MySQL
- MongoDB
- Redis
- Elasticsearch
- Jenkins
- SonarQube

They ensure that application data persists even when containers are stopped, removed, or recreated.

#### Q: -> What is a Docker Named Volume, and why would you use one?

A Docker Named Volume is a Docker-managed storage location that exists independently of containers. It is used to persist application data across container restarts and recreations. Named volumes are commonly used with databases and other stateful applications because removing a container does not delete the data stored in the volume.


# Task 3: Bind Mounts

In this Task we will learn how **BIND MOUNTS** a Docker container to directly use files from our HOST machine. Ulike named Volumes , bind mounts points to a specific directory on our computer, Making them ideal for devlopment because changes on the host are immediately reflected inside the container.

### Step 1: Create a Folder on our Host

Create a new directory:

```bash 
mkdir my-website-on-host
cd my-website-on-host
```
Create an `index.html` file:
```HTML
vi index.html 

# Add the following content:

<!DOCTYPE html>
<html>
<head>
    <title>Docker Bind Mount Demo</title>
</head>
<body>
    <h1>Hello from Bind Mount!</h1>
    <p>This page is served from my host machine.</p>
</body>
</html>
```

Verify the file:
```bash 
cat index.html 
```
OUTOUT:

![alt text](image-7.png)

### Step 2: Run an Nginx Container with a Bind Mount
Run the container:
```bash  
docker run -d --name nginx-bind -p 8080:80 -v $(pwd):/usr/share/nginx/html nginx:alpine
```

Understanding the `-v` Option

`$(pwd):/usr/share/nginx/html`

| Part                    | Meaning                                  |
| ----------------------- | ---------------------------------------- |
| `$(pwd)`                | Current directory on your host machine   |
| `/usr/share/nginx/html` | Nginx web directory inside the container |

- This means Nginx serves files directly from our local folder.

### Step 3: Access the Website

Open your browser and visit:
```bash 
http://localhost:8080
```

we should see:

OUTPUT: 
![alt text](image-8.png)

### Step 4: Edit the File on Your Host

Modify `index.html`:

```HTML 
<!DOCTYPE html>
<html>
<head>
    <title>Docker Bind Mount Demo</title>
</head>
<body>
    <h1>Hello Docker!</h1>
    <p>I edited this file without rebuilding the image.</p>
</body>
</html>
```
Save the file.Refesh the browser we should immediately see:

OUTPUT : 
![alt text](image-9.png)

### Step 5: Verify the Mount

Inspect the container:
```bash 
docker inspect nginx-bind
```
Look for the Mounts section:
```
OUTOUT: 
![alt text](image-10.png)

- This confirms that Docker is using Bind Mounts

Stop and Remove the Container
```bash 
docker stop nginx-bind && docker rm nginx-bind
```
- Our `index.html` file remains on our host machine Because Docker never owned it 

### Architecture

```
Host Machine
-------------------------
my-website/
└── index.html
        │
        │ Bind Mount
        ▼
Docker Container
-------------------------
/usr/share/nginx/html
        │
        ▼
Nginx Web Server
        │
        ▼
http://localhost:8080
```
## Named Volume vs Bind Mount

| Feature                 | Named Volume                           | Bind Mount                                    |
| ----------------------- | -------------------------------------- | --------------------------------------------- |
| Storage Location        | Managed by Docker                      | Specific directory on the host                |
| Managed By              | Docker                                 | User                                          |
| Easy to Share with Host | No                                     | Yes                                           |
| Best For                | Databases, persistent application data | Development, source code, configuration files |
| Data Visible on Host    | Stored in Docker's internal directory  | Stored directly in your chosen host directory |
| Platform Independence   | High                                   | Depends on host filesystem paths              |

#### Q -> What is the difference between a Named Volume and a Bind Mount?

A **Named Volume** is managed entirely by Docker and is primarily used for persistent application data such as databases. Docker decides where the data is stored, and the data remains available even after containers are removed.

A **Bind Mount** directly maps a directory or file from the host machine into a container. Any changes made on the host are immediately reflected inside the container, making bind mounts ideal for development workflows where code changes need to be visible without rebuilding the Docker image.

#### Q: When would you use a Bind Mount instead of a Named Volume?

Use a **Bind Mount** during development when you need to edit source code or configuration files on our host machine and see the changes instantly inside the container. 

Use a **Named Volume** for persistent application data, especially databases, where Docker-managed storage provides better portability and isolation.

