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


