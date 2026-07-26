# Task 1: Build Your Own App Stack (Flask + MySQL + Redis)

In this task we will build a real-world 3-tier applications using Docker Compose.

The stack consists of:

- Flask – Web application
- MySQL – Database
- Redis – Cache
- Docker Compose – Orchestrates all services
- Custom Dockerfile – Builds the Flask application image

The Flask application will:

- Connect to MySQL
- Verify the database connection
- Connect to Redis
- Display a success message in the browser

#### Project Structure
```
flask-app-stack/
│
├── docker-compose.yml
│
└── web/
    ├── Dockerfile
    ├── app.py
    └── requirements.txt
```
Create the project:

```bash 
mkdir flask-app-stack
cd flask-app-stack

mkdir web
cd web

touch Dockerfile app.py requirements.txt

cd ..
touch docker-compose.yml
```

### Step 1: Create the Flask Application
`app.py`

```python 
from flask import Flask
import mysql.connector
import redis
import time

app = Flask(__name__)

# Wait for MySQL
db = None
while db is None:
    try:
        db = mysql.connector.connect(
            host="db",
            user="appuser",
            password="apppassword",
            database="myapp"
        )
    except Exception:
        print("Waiting for MySQL...")
        time.sleep(3)

# Connect to Redis
cache = redis.Redis(host="redis", port=6379)

@app.route("/")
def home():
    cursor = db.cursor()

    cursor.execute("SELECT NOW();")
    current_time = cursor.fetchone()[0]

    cache.set("status", "Connected")

    redis_status = cache.get("status").decode()

    return f"""
    <h1>Docker Compose Demo</h1>

    <p><b>MySQL:</b> Connected</p>

    <p>Database Time:
    {current_time}</p>

    <p><b>Redis:</b>
    {redis_status}</p>
    """

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

### Step 2: Create requirements.txt
```bash 
Flask==3.1.0
mysql-connector-python==9.2.0
redis==5.2.1
```

### Step 3: Create the Dockerfile

```Dockerfile 
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
```
Understanding the Dockerfile

| Instruction | Purpose                            |
| ----------- | ---------------------------------- |
| FROM        | Base Python image                  |
| WORKDIR     | Working directory inside container |
| COPY        | Copy application files             |
| RUN         | Install Python dependencies        |
| EXPOSE      | Document application port          |
| CMD         | Start the Flask application        |


### Step 4: Create `docker-compose.yml`

```YAML
services:

  web:
    build: ./web
    container_name: flask-app

    ports:
      - "5000:5000"

    depends_on:
      - db
      - redis

    environment:
      DB_HOST: db
      DB_NAME: myapp
      DB_USER: appuser
      DB_PASSWORD: apppassword
      REDIS_HOST: redis

  db:
    image: mysql:8.0

    container_name: mysql-db

    restart: always

    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: myapp
      MYSQL_USER: appuser
      MYSQL_PASSWORD: apppassword

    volumes:
      - mysql-data:/var/lib/mysql

  redis:
    image: redis:7-alpine

    container_name: redis-cache

    restart: always

volumes:
  mysql-data:

```

### Step 5: Build the Stack

```bash 
docker compose build 
```
### Step 6: Start Everything

```bash 
docker compose up -d
```
Verify:
```bash 
docker compose ps 
```

OUTPUT: 
![alt text](image.png)


### Step 7: View Logs

```bash 
docker compose logs web
```
Follow logs:
```bash 
docker compose logs -f web 
```

### Step 8: Access the Application

Open:
```bash 
http://localhost:5000
```
OUTPUT: 
![alt text](image-1.png)

### Step 9: Verify MySQL

```bash 
docker exec -it mysql-db mysql -u appuser -p
```
Password:
```
apppassword
```
Verify:
```sql
SHOW DATABASES;
```
OUTPUT: 
![alt text](image-2.png)

### Step 10: Verify Redis

Enter Redis:
```bash 
docker exec -it redis-cache redis-cli 
```
Check the stored key:
```bash
GET status
```
Output:
![alt text](image-3.png)


Architecture
```
                 Docker Compose

             flask-app-stack
                     │
     ┌───────────────┼───────────────┐
     │               │               │
     ▼               ▼               ▼
 Flask App       MySQL DB         Redis
 (Python)        (Persistent)     (Cache)
     │               ▲
     │               │
     └────── Connects ┘
     │
     └──────── Connects to Redis

Browser
http://localhost:5000
```

### IMPT Q: How do containers communicate with each other in a Docker Compose application?

Docker Compose automatically creates a user-defined bridge network for the project. Each service is registered in Docker's internal DNS using its service name. Instead of using IP addresses, containers communicate by referring to service names such as db for MySQL or redis for Redis. This makes the application more portable and resilient because service names remain constant even if container IP addresses change.





