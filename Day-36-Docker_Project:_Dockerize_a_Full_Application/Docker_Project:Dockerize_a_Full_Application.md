# Task 1: Pick Your App

### The app: A three-tier real-time chat application:

- **Frontend**: HTML/CSS/JS chat UI + history viewer

- **Backend**: Go server (WebSockets for live chat + REST API for history)

- **Database**: MySQL for storing messages

#### Why we picked it:

- Clean **three-tier structure** — good match for standard DevOps setups (frontend, app server, database)

- Uses **WebSockets**, a stateful, long-lived connection — more realistic and challenging than a typical stateless CRUD app

- Has a **real database dependency**, so we get to handle things like connection config, migrations, and credentials

- Go compiles to a **single lightweight binary**, great for small, fast Docker images

- It's a small, simple codebase — easy to containerize, deploy, and improve step by step as we go through tasks

- It currently has real issues (hardcoded credentials, no auth, open CORS) — good practice material for later hardening tasks


### Step 1: Set up the project folder
```bash 
mkdir -p ~/chat-app
cd ~/chat-app
```
- Now create `main.go`, `index.html`, `history.html`, and `go.mod`

### Step 2: Create `go.mod`
Run this to create the file:

```bash 
vi go.mod
```

OR

```bash 
cat > ~/chat-app/go.mod << 'EOF'
module chatapp

go 1.22

require (
	github.com/gorilla/websocket v1.5.3
	gorm.io/driver/mysql v1.5.7
	gorm.io/gorm v1.25.11
)
EOF

```
Verify it:
```bash 
cat ~/chat-app/go.mod
```

### Step 3: Create `main.go`

This is the backend — WebSocket handler, REST API, MySQL via GORM, with env-var-based DB config

```bash 
vi main.go 
```
OR 

```bash 
cat > ~/chat-app/main.go << 'EOF'
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gorilla/websocket"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

var db *gorm.DB

type ClientKey struct {
	From string
	To   string
}

var clients = make(map[ClientKey]*websocket.Conn)

type Message struct {
	ID         uint      `gorm:"primaryKey"`
	Datetime   time.Time `gorm:"autoCreateTime"`
	FromUser   string
	ToUser     string
	MsgContent string
}

type ChatHistoryResponse struct {
	Messages []ChatHistoryMessage `json:"messages"`
}

type ChatHistoryMessage struct {
	Timestamp string `json:"timestamp"`
	FromUser  string `json:"from"`
	ToUser    string `json:"to"`
	Content   string `json:"content"`
}

// getEnv returns the value of key if set, otherwise fallback.
func getEnv(key, fallback string) string {
	if v, ok := os.LookupEnv(key); ok && v != "" {
		return v
	}
	return fallback
}

func main() {
	dbHost := getEnv("DB_HOST", "127.0.0.1")
	dbPort := getEnv("DB_PORT", "3306")
	dbUser := getEnv("DB_USER", "root")
	dbPassword := getEnv("DB_PASSWORD", "")
	dbName := getEnv("DB_NAME", "chatdb")
	appPort := getEnv("APP_PORT", "8080")

	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=True&loc=Local",
		dbUser, dbPassword, dbHost, dbPort, dbName)

	var err error
	db, err = gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal(" Failed to connect to DB:", err)
	}

	db.AutoMigrate(&Message{})

	http.HandleFunc("/ws", handleConnection)

	http.HandleFunc("/api/chat-history", handleChatHistory)

	// Serve static files (for the chat interface)
	http.Handle("/", http.FileServer(http.Dir(".")))

	fmt.Printf("Chat server started at http://localhost:%s\n", appPort)
	fmt.Printf("WebSocket endpoint: ws://localhost:%s/ws\n", appPort)
	log.Fatal(http.ListenAndServe(":"+appPort, nil))
}

func handleConnection(w http.ResponseWriter, r *http.Request) {
	fromUser := r.URL.Query().Get("from")
	toUser := r.URL.Query().Get("to")

	connKey := ClientKey{From: fromUser, To: toUser}

	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println(" Upgrade error:", err)
		return
	}
	defer conn.Close()

	log.Printf(" %s connected to chat with %s\n", fromUser, toUser)

	clients[connKey] = conn
	defer delete(clients, connKey)

	sendChatHistory(conn, fromUser, toUser)

	for {
		_, msg, err := conn.ReadMessage()
		if err != nil {
			log.Printf(" %s disconnected from chat with %s\n", fromUser, toUser)
			break
		}

		currentTime := time.Now()
		timestamp := currentTime.Format("2006-01-02 15:04")

		message := Message{
			FromUser:   fromUser,
			ToUser:     toUser,
			MsgContent: string(msg),
			Datetime:   currentTime,
		}
		db.Create(&message)

		formatted := fmt.Sprintf("[%s] %s → %s: %s", timestamp, fromUser, toUser, msg)

		conn.WriteMessage(websocket.TextMessage, []byte(formatted))

		// Send to recipient only in chats where To=A and From=C
		for key, toConn := range clients {
			if key.From == toUser && key.To == fromUser {
				toConn.WriteMessage(websocket.TextMessage, []byte(formatted))
			}
		}
	}
}

func sendChatHistory(conn *websocket.Conn, user1, user2 string) {
	var history []Message
	db.
		Where("(from_user = ? AND to_user = ?) OR (from_user = ? AND to_user = ?)",
			user1, user2, user2, user1).
		Order("datetime").
		Find(&history)

	for _, msg := range history {
		timestamp := msg.Datetime.Format("2006-01-02 15:04")
		formatted := fmt.Sprintf("[%s] %s → %s: %s", timestamp, msg.FromUser, msg.ToUser, msg.MsgContent)
		conn.WriteMessage(websocket.TextMessage, []byte(formatted))
	}
}

func handleChatHistory(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	fromUser := r.URL.Query().Get("from")
	toUser := r.URL.Query().Get("to")
	startTimeStr := r.URL.Query().Get("start_time")
	endTimeStr := r.URL.Query().Get("end_time")

	if fromUser == "" || toUser == "" {
		http.Error(w, "Missing required parameters: from and to", http.StatusBadRequest)
		return
	}

	var startTime, endTime time.Time
	var err error

	if startTimeStr != "" {
		startTime, err = time.Parse("2006-01-02 15:04:05", startTimeStr)
		if err != nil {
			http.Error(w, "Invalid start_time format. Use YYYY-MM-DD HH:MM:SS", http.StatusBadRequest)
			return
		}
	} else {
		startTime = time.Now().AddDate(0, 0, -7)
	}

	if endTimeStr != "" {
		endTime, err = time.Parse("2006-01-02 15:04:05", endTimeStr)
		if err != nil {
			http.Error(w, "Invalid end_time format. Use YYYY-MM-DD HH:MM:SS", http.StatusBadRequest)
			return
		}
	} else {
		endTime = time.Now()
	}

	var messages []Message
	result := db.Where("((from_user = ? AND to_user = ?) OR (from_user = ? AND to_user = ?)) AND datetime BETWEEN ? AND ?",
		fromUser, toUser, toUser, fromUser, startTime, endTime).
		Order("datetime").
		Find(&messages)

	if result.Error != nil {
		http.Error(w, "Failed to retrieve chat history: "+result.Error.Error(), http.StatusInternalServerError)
		return
	}

	response := ChatHistoryResponse{
		Messages: make([]ChatHistoryMessage, 0, len(messages)),
	}

	for _, msg := range messages {
		response.Messages = append(response.Messages, ChatHistoryMessage{
			Timestamp: msg.Datetime.Format("2006-01-02 15:04:05"),
			FromUser:  msg.FromUser,
			ToUser:    msg.ToUser,
			Content:   msg.MsgContent,
		})
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}
EOF
```

### Step 4: Create `index.html`
This is the chat UI served at `/`.

```bash 
cat > ~/chat-app/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Go Real-Time Chat</title>
  <style>
    body {
      font-family: 'Segoe UI', sans-serif;
      background-color: #e9edf0;
      display: flex;
      flex-direction: column;
      align-items: center;
      margin: 0;
      padding: 0;
    }

    h2 {
      margin-top: 20px;
      color: #333;
    }

    #chat-header {
      width: 90%;
      max-width: 600px;
      text-align: center;
      padding: 10px;
      font-size: 0.9em;
      color: #666;
      position: sticky;
      top: 0;
      background-color: #e9edf0;
      z-index: 1;
    }

    #chat {
      width: 90%;
      max-width: 600px;
      height: 500px;
      background-color: #fff;
      border-radius: 8px;
      box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
      overflow-y: auto;
      padding: 15px;
      margin-bottom: 10px;
      display: flex;
      flex-direction: column;
      gap: 10px;
    }

    .message {
      position: relative;
      padding: 10px 15px 30px 15px;
      border-radius: 15px;
      max-width: 75%;
      word-wrap: break-word;
      white-space: pre-wrap;
      min-width: 100px;
      min-height: 40px;
    }

    .self {
      background-color: #dcf8c6;
      align-self: flex-end;
    }

    .other {
      background-color: #f1f0f0;
      align-self: flex-start;
    }

    .timestamp {
      font-size: 0.75em;
      color: #777;
      position: absolute;
      bottom: 6px;
      right: 12px;
    }

    .system {
      align-self: center;
      font-size: 0.9em;
      color: #888;
    }

    #input-area {
      width: 90%;
      max-width: 600px;
      display: flex;
      gap: 10px;
      margin-bottom: 20px;
    }

    #msg {
      flex-grow: 1;
      padding: 10px 15px;
      border: 1px solid #ccc;
      border-radius: 20px;
      font-size: 1em;
    }

    button {
      padding: 10px 20px;
      background-color: #4caf50;
      color: white;
      border: none;
      border-radius: 20px;
      cursor: pointer;
      font-size: 1em;
    }

    button:hover {
      background-color: #45a049;
    }

    .history-link {
      margin-top: 10px;
      color: #4caf50;
      text-decoration: none;
    }

    .history-link:hover {
      text-decoration: underline;
    }
  </style>
</head>
<body>
  <h2>Real-Time Chat</h2>

  <div id="chat-header" class="system">You are chatting with ...</div>

  <div id="chat"></div>

  <div id="input-area">
    <input type="text" id="msg" placeholder="Type your message..." />
    <button onclick="sendMessage()">Send</button>
  </div>

  <a href="history.html" class="history-link">View Chat History</a>

  <script>
    const from = prompt("Your name?");
    const to = prompt("Who are you chatting with?");
    const chatBox = document.getElementById("chat");
    const header = document.getElementById("chat-header");

    const ws = new WebSocket(`ws://localhost:8080/ws?from=${from}&to=${to}`);

    ws.onopen = () => {
      header.textContent = "You are chatting with " + to;
    };

    ws.onmessage = (event) => {
      const raw = event.data;
      const match = raw.match(/^\[(.*?)\] (.*?) → (.*?): (.*)$/);

      if (!match) {
        appendSystemMessage(raw);
        return;
      }

      const [, datetime, fromUser, , message] = match;
      const isOwn = fromUser === from;

      appendMessage(message, datetime, isOwn ? 'self' : 'other');
    };

    ws.onerror = (e) => {
      appendSystemMessage("WebSocket error");
      console.error(e);
    };

    ws.onclose = () => {
      appendSystemMessage("Disconnected");
    };

    function sendMessage() {
      const msgInput = document.getElementById("msg");
      const msg = msgInput.value;
      if (msg.trim() !== "") {
        ws.send(msg);
        msgInput.value = "";
      }
    }

    function appendMessage(text, time, type) {
      const bubble = document.createElement("div");
      bubble.classList.add("message", type);
      bubble.textContent = text;

      const timeEl = document.createElement("div");
      timeEl.classList.add("timestamp");
      timeEl.textContent = time;

      bubble.appendChild(timeEl);
      chatBox.appendChild(bubble);
      chatBox.scrollTop = chatBox.scrollHeight;
    }

    function appendSystemMessage(msg) {
      const line = document.createElement("div");
      line.textContent = msg;
      line.classList.add("system");
      chatBox.appendChild(line);
      chatBox.scrollTop = chatBox.scrollHeight;
    }

    document.getElementById("msg").addEventListener("keypress", function(event) {
      if (event.key === "Enter") {
        sendMessage();
      }
    });
  </script>
</body>
</html>
EOF
```

### Step 5: Create `history.html`

This is the chat history browser UI.

Run this: 
```bash 
cat > ~/chat-app/history.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Chat History</title>
  <style>
    body {
      font-family: 'Segoe UI', sans-serif;
      background-color: #e9edf0;
      display: flex;
      flex-direction: column;
      align-items: center;
      margin: 0;
      padding: 0;
    }

    h2 {
      margin-top: 20px;
      color: #333;
    }

    .container {
      width: 90%;
      max-width: 800px;
      margin: 20px auto;
    }

    .form-group {
      margin-bottom: 15px;
    }

    label {
      display: block;
      margin-bottom: 5px;
      font-weight: bold;
      color: #555;
    }

    input, button {
      padding: 10px;
      border-radius: 5px;
      border: 1px solid #ccc;
      width: 100%;
      font-size: 14px;
    }

    .form-row {
      display: flex;
      gap: 15px;
      margin-bottom: 15px;
    }

    .form-row > div {
      flex: 1;
    }

    button {
      background-color: #4caf50;
      color: white;
      border: none;
      cursor: pointer;
      font-weight: bold;
      margin-top: 10px;
    }

    button:hover {
      background-color: #45a049;
    }

    #results {
      background-color: #fff;
      border-radius: 8px;
      box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
      padding: 20px;
      margin-top: 20px;
      min-height: 300px;
      max-height: 600px;
      overflow-y: auto;
    }

    .message {
      position: relative;
      padding: 10px 15px;
      border-radius: 15px;
      margin-bottom: 15px;
      word-wrap: break-word;
      white-space: pre-wrap;
    }

    .timestamp {
      display: block;
      font-size: 0.75em;
      color: #777;
      margin-top: 5px;
    }

    .user-from {
      background-color: #dcf8c6;
      margin-left: 20%;
    }

    .user-to {
      background-color: #f1f0f0;
      margin-right: 20%;
    }

    .no-messages {
      color: #888;
      text-align: center;
      padding: 40px 0;
    }

    .back-link {
      display: inline-block;
      margin-top: 20px;
      color: #4caf50;
      text-decoration: none;
    }

    .back-link:hover {
      text-decoration: underline;
    }
  </style>
</head>
<body>
  <div class="container">
    <h2>Chat History</h2>

    <form id="historyForm">
      <div class="form-row">
        <div class="form-group">
          <label for="fromUser">From User:</label>
          <input type="text" id="fromUser" required placeholder="Your username">
        </div>

        <div class="form-group">
          <label for="toUser">To User:</label>
          <input type="text" id="toUser" required placeholder="Other username">
        </div>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label for="startDate">Start Date & Time:</label>
          <input type="datetime-local" id="startDate">
        </div>

        <div class="form-group">
          <label for="endDate">End Date & Time:</label>
          <input type="datetime-local" id="endDate">
        </div>
      </div>

      <button type="submit">Get Chat History</button>
    </form>

    <div id="results">
      <div class="no-messages">Enter user details and time range to view chat history</div>
    </div>

    <a href="index.html" class="back-link">← Back to Chat</a>
  </div>

  <script>
    document.getElementById('historyForm').addEventListener('submit', function(e) {
      e.preventDefault();

      const fromUser = document.getElementById('fromUser').value;
      const toUser = document.getElementById('toUser').value;
      let startDate = document.getElementById('startDate').value;
      let endDate = document.getElementById('endDate').value;

      if (startDate) {
        startDate = startDate.replace('T', ' ') + ':00';
      }

      if (endDate) {
        endDate = endDate.replace('T', ' ') + ':00';
      }

      let url = `/api/chat-history?from=${encodeURIComponent(fromUser)}&to=${encodeURIComponent(toUser)}`;
      if (startDate) {
        url += `&start_time=${encodeURIComponent(startDate)}`;
      }
      if (endDate) {
        url += `&end_time=${encodeURIComponent(endDate)}`;
      }

      fetch(url)
        .then(response => {
          if (!response.ok) {
            throw new Error('Network response was not ok');
          }
          return response.json();
        })
        .then(data => {
          displayChatHistory(data, fromUser);
        })
        .catch(error => {
          console.error('Error fetching chat history:', error);
          document.getElementById('results').innerHTML = `
            <div class="no-messages">Error fetching chat history: ${error.message}</div>
          `;
        });
    });

    function displayChatHistory(data, currentUser) {
      const resultsDiv = document.getElementById('results');

      if (!data.messages || data.messages.length === 0) {
        resultsDiv.innerHTML = '<div class="no-messages">No messages found for the selected period</div>';
        return;
      }

      let html = '';

      data.messages.forEach(msg => {
        const isFromCurrentUser = msg.from === currentUser;
        const cssClass = isFromCurrentUser ? 'user-from' : 'user-to';

        html += `
          <div class="message ${cssClass}">
            <strong>${msg.from}:</strong> ${msg.content}
            <span class="timestamp">${msg.timestamp}</span>
          </div>
        `;
      });

      resultsDiv.innerHTML = html;
      resultsDiv.scrollTop = resultsDiv.scrollHeight;
    }

    window.addEventListener('DOMContentLoaded', () => {
      const now = new Date();
      const weekAgo = new Date();
      weekAgo.setDate(weekAgo.getDate() - 7);

      document.getElementById('endDate').value = formatDateForInput(now);
      document.getElementById('startDate').value = formatDateForInput(weekAgo);
    });

    function formatDateForInput(date) {
      return date.toISOString().slice(0, 16);
    }
  </script>
</body>
</html>
EOF
```

# Task 2: Write the Dockerfile

```Dockerfile 
cat > ~/chat-app/Dockerfile << 'EOF'
# syntax=docker/dockerfile:1

# ---------- Stage 1: Build ----------
FROM golang:1.22-alpine AS builder

# Needed to build gorm's mysql driver / any cgo-adjacent deps cleanly
RUN apk add --no-cache git ca-certificates

WORKDIR /src

# Cache dependency downloads separately from source changes
COPY go.mod go.sum* ./
RUN go mod download

COPY main.go ./

# Static binary: no CGO, stripped symbols, target linux
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /out/chat-server .

# ---------- Stage 2: Runtime ----------
FROM alpine:3.20 AS runtime

# TLS root certs (for outbound HTTPS if ever needed) + tzdata for correct timestamps
RUN apk add --no-cache ca-certificates tzdata \
    && addgroup -S appgroup \
    && adduser -S -G appgroup -H -h /app appuser

WORKDIR /app

# Binary + static frontend assets served by http.FileServer
COPY --from=builder /out/chat-server ./chat-server
COPY index.html history.html ./

# Ensure the non-root user owns everything it needs to read/execute
RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8080

# Basic container-level healthcheck against the REST endpoint
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider "http://127.0.0.1:8080/api/chat-history?from=healthcheck&to=healthcheck" || exit 1

ENTRYPOINT ["./chat-server"]
EOF

```

Also create a Dockerignore file `.dockerignore`
```dockerfile

cat > ~/chat-app/.dockerignore << 'EOF'
# VCS
.git
.gitignore

# Docs
*.md
README*

# Local env / secrets
.env
.env.*
*.pem
*.key

# OS/editor cruft
.DS_Store
.vscode
.idea

# Build artifacts
chat-server
*.exe
*.test
*.out
dist/
bin/

# Dependency/cache dirs (not used here, but safe defaults)
node_modules
vendor/

# Docker itself
Dockerfile
docker-compose*.yml
.dockerignore
EOF
```

This is a production-style **multi-stage Dockerfile** for a **Go chat application**. I'll explain the exact file section by section

1. Overall architecture
The Dockerfile has two stages:

```
                    Docker Build
                         │
          ┌──────────────┴──────────────┐
          │                             │
          ▼                             ▼
   Stage 1: builder              Stage 2: runtime
   golang:1.22-alpine             alpine:3.20
          │                             │
   Download dependencies                │
   Copy Go source                       │
   Compile application                  │
          │                             │
          │ chat-server binary          │
          └──────────────►               │
                                        │
                              Copy binary + HTML
                                        │
                                        ▼
                              Final Docker Image
                              Runs as appuser
                                        │
                                        ▼
                                  Port 8080
```
The important idea is:

Stage 1 builds the application. Stage 2 only contains what is required to run it.

2. Dockerfile syntax version
```dockerfile
# syntax=docker/dockerfile:1
```
- This tells Docker which Dockerfile syntax/frontend to use.

- The `1` refers to Docker's versioned Dockerfile syntax.

- It isn't part of our application. It controls how Docker interprets the Dockerfile.

3. Stage 1 — Build
```dockerfile
FROM golang:1.22-alpine AS builder
```
This starts the first stage.

we're using:
```
golang:1.22-alpine
```
which contains:
- Alpine Linux
- Go 1.22
- Go compiler
- Go tooling

And:
```dockerfile
AS builder
```
gives this stage a name:
```
builder
```
 we use that name later here:
 ```dockerfile 
 COPY --from=builder
 ```

 4. Install build dependencies

 ```dockerfile 
 RUN apk add --no-cache git ca-certificates
 ```
 `apk` is Alpine Linux's package manager.

we're installing:

`git`

- Required if Go needs to retrieve dependencies from Git repositories.

`ca-certificates`

- Provides trusted CA certificates for HTTPS connections.

`--no-cache`
- Prevents Alpine's package index from being retained in the image, helping keep the layer smaller.

So:
```bash 
golang:1.22-alpine
        │
        ├── git
        └── ca-certificates
```

5. Set the working directory
```dockerfile 
WORKDIR /src
```
Docker creates:
```
/src
```
and makes it the current directory for subsequent commands.

So:
```dockerfile 
COPY ...
RUN go mod download
```

will operate inside:
```
/src
```

6. Copy Go dependency files
```dockerfile 
COPY go.mod go.sum* ./
```
- This copies our Go dependency files into /src.

Normally we'll have:
```
go.mod
go.sum
```
The `*` means `go.sum` can be absent without causing the `COPY` to fail.

This is useful because the dependency files are copied separately from the source code.

7. Download dependencies
```dockerfile
RUN go mod download
```
Go downloads the dependencies defined in `go.mod`.

For example, our application might use:
```
GORM
MySQL driver
Gin
gorilla/websocket
```
Those dependencies are downloaded into the Go module cache

Why is this separated from `COPY main.go?`

Because of **Docker layer caching**.

Suppose you change only:
```
main.go
```
Docker can reuse:
```
COPY go.mod go.sum*
RUN go mod download
```
instead of downloading all dependencies again.
That's a very common Docker optimization.

8. Copy application source
```dockerfile
COPY main.go ./
```
Now your Go source is copied into:
```
/src/main.go
```
At this point:
```
/src
├── go.mod
├── go.sum
└── main.go
```
9. Build the Go application

```dockerfile 
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /out/chat-server .
```
This is the most important build command.
Let's break it down.

`CGO_ENABLED=0`
```
CGO_ENABLED=0
```
Disables CGO.

This helps produce a statically linked Go binary that doesn't depend on system C libraries.

`GOOS=linux`

```
GOOS=linux
```
Tells GO: Build this application for Linux.
That's appropriate because the runtime container is Linux-based.

`go build`

```
go build
```
Compiles our Go application.
The:
```
.
```
means:
Build the Go application in the current directory.

`-ldflags="-s -w"`
These options reduce binary size.
```
-s
```
removes symbol information.
```
-w
```
removes DWARF debugging information.

So the resulting executable is smaller.

`-o /out/chat-server`
This specifies the output location/name:
```
/out/chat-server
```
So after compilation:
```
/src/main.go
       │
       ▼
 Go Compiler
       │
       ▼
/out/chat-server
```

10. Stage 2 — Runtime
```dockerfile 
FROM alpine:3.20 AS runtime
```

- Now Docker starts a **new image stage**.
- This is extremely important.
- The final image does not use the entire `golang:1.22-alpine` environment.

Instead, it starts with:
```
alpine:3.20
```
which is much smaller.
The Go compiler isn't needed anymore because compilation is finished.

11. Install runtime packages and create user

our intended command is:
```dockerfile 

RUN apk add --no-cache ca-certificates tzdata \
    && addgroup -S appgroup \
    && adduser -S -G appgroup -H -h /app appuser

```
This performs three things.

Install certificates
```
ca-certificates
```
- Allows the application to make HTTPS connections and validate TLS certificates.

Install timezone data
```
tzdata
```
Provides timezone information.
That's useful if our application needs correct local/timezone handling.

Create group
```
addgroup -S appgroup
```
Creates a system group:
```
appgroup
```

Create user
```
adduser -S -G appgroup -H -h /app appuser
```
Creates:
```
appuser
```
and associates it with:
```
appgroup
```
The important security point is that our application won't run as root.

12. Set runtime working directory
```docekerfile 
WORKDIR /app
```
The application will run from:

```
/app
```
13. Copy the compiled binary

```dockerfile 
COPY --from=builder /out/chat-server ./chat-server
```
This is the key multi-stage-build instruction.
It says:

Go to the `builder` stage and copy `/out/chat-server` into `/app/chat-server` in the runtime image.

So:
```
Stage 1

/out/chat-server
       │
       │ COPY --from=builder
       ▼
Stage 2

/app/chat-server
```
You don't copy:
- Go compiler
- Go SDK
- source code
- build cache
- Git

Only the executable.

14. Copy frontend files
```dockerfile 
COPY index.html history.html ./
```

These files are copied into:
```
/app
```
So the runtime filesystem looks roughly like:
```
/app
├── chat-server
├── index.html
└── history.html
```
our Go application apparently serves these static files using:
```
http.FileServer
```

15. Change ownership

```dockerfile 
RUN chown -R appuser:appgroup /app
```
Changes ownership of everything inside `/app`:
```
/app
├── chat-server
├── index.html
└── history.html
```
to:

```
appuser:appgroup
```
- This ensures the non-root user can access the application files.

16. Switch away from root
```dockerfile 
USER appuser
```
This is an important security practice.
From this point onward, commands and the application run as:
```
appuser
```

instead of:
```
root 
```
So if your application is compromised, the attacker doesn't automatically have root privileges inside the container.

17. Document port 8080

```dockerfile
EXPOSE 8080
```
This documents that the application listens on:
```
8080
```
Important:

`EXPOSE` does not publish the port to your host.

you  still need something like:
```bash 
docker run -p 8080:8080 ...
```
To access it from your machine.

18. Healthcheck
```dockerfile 

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
CMD wget --no-verbose --tries=1 --spider "http://127.0.0.1:8080/api/chat-history?from=healthcheck&to=healthcheck" || exit 1

```
This tells Docker how to determine whether our application is healthy.

The endpoint being checked is:
```
/api/chat-history
```
with:
```
from=healthcheck
to=healthcheck
```

`--interval=30s`
Docker checks the application every:

```
30 seconds
```
`--timeout=3s`
If the healthcheck doesn't respond within:
```
3 seconds
```
the check fails.

`--start-period=5s`

After the container starts, Docker gives the application:

```
5 seconds
```
before healthcheck failures start counting.

`--retries=3`
The application needs to fail the healthcheck three consecutive times before Docker considers it unhealthy.

Conceptually:
```
Container starts
      │
      ▼
Wait 5 seconds
      │
      ▼
Healthcheck every 30 seconds
      │
      ├── Success → healthy
      │
      └── Failure
            │
            ▼
         retry
            │
            ▼
         retry
            │
            ▼
       3 failures
            │
            ▼
        unhealthy
```

19. `wget` healthcheck command
```bash 
wget --no-verbose --tries=1 --spider "http://127.0.0.1:8080/api/chat-history..."
```
`wget` attempts to access the endpoint.

`--no-verbose` -> Reduces output.
`--tries=1` -> Only tries once.
`--spider` -> Checks the URL without downloading the response body.

So essentially:
- Can I successfully reach this API endpoint?

If it works:
```
exit code 0
```
If it fails:
```
exit 1
```
because of:
```bash
|| exit 1
```
20. ENTRYPOINT
```dockerfile 
ENTRYPOINT ["./chat-server"]
```
This defines the main application that the container runs.
When you execute:

```bash 
docker run your-image
```
Docker effectively starts:
```
./chat-server
```
So the final container looks like:
```
Alpine Linux
     │
     ├── ca-certificates
     ├── tzdata
     │
     └── /app
          ├── chat-server
          ├── index.html
          └── history.html
```
and:
```
USER = appuser
PORT = 8080
ENTRYPOINT = ./chat-server
```


### Complete Build Flow

This is the most important thing to understand from this Dockerfile:
```
                   docker build
                        │
                        ▼
        ┌─────────────────────────────┐
        │ Stage 1: builder             │
        │                              │
        │ golang:1.22-alpine           │
        │                              │
        │ go.mod + go.sum              │
        │       ↓                      │
        │ go mod download              │
        │       ↓                      │
        │ main.go                      │
        │       ↓                      │
        │ go build                     │
        │       ↓                      │
        │ /out/chat-server             │
        └──────────────┬──────────────┘
                       │
                       │ COPY --from=builder
                       ▼
        ┌─────────────────────────────┐
        │ Stage 2: runtime             │
        │                              │
        │ alpine:3.20                  │
        │                              │
        │ ca-certificates              │
        │ tzdata                       │
        │                              │
        │ /app/chat-server             │
        │ /app/index.html              │
        │ /app/history.html            │
        │                              │
        │ USER appuser                 │
        │                              │
        │ PORT 8080                    │
        └─────────────────────────────┘
                       │
                       ▼
                Final Image
```

### Why this is a good production-style Dockerfile

| Practice               | Where it appears                      |
| ---------------------- | ------------------------------------- |
| Multi-stage build      | `FROM ... AS builder` + `COPY --from` |
| Small runtime image    | `alpine:3.20`                         |
| Dependency caching     | `COPY go.mod go.sum*` before source   |
| Static Go binary       | `CGO_ENABLED=0`                       |
| Smaller binary         | `-ldflags="-s -w"`                    |
| Non-root execution     | `USER appuser`                        |
| Explicit base versions | `golang:1.22-alpine`, `alpine:3.20`   |
| Health monitoring      | `HEALTHCHECK`                         |
| TLS support            | `ca-certificates`                     |
| Timezone support       | `tzdata`                              |
| Frontend assets        | `index.html`, `history.html`          |
| Application port       | `EXPOSE 8080`                         |

The key takeaway: Stage 1 is your factory—it contains everything needed to build the application. Stage 2 is your production box—it contains only the things required to run the already-built application.




# Task 3: Add Docker Compose

Create `docker-compose.yml`

```bash 
cat > ~/chat-app/docker-compose.yml << 'EOF'
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: chat-app:latest
    container_name: chat-app
    restart: unless-stopped
    ports:
      - "${APP_PORT:-8080}:8080"
    environment:
      APP_PORT: "8080"
      DB_HOST: db
      DB_PORT: "3306"
      DB_USER: ${MYSQL_USER}
      DB_PASSWORD: ${MYSQL_PASSWORD}
      DB_NAME: ${MYSQL_DATABASE}
    depends_on:
      db:
        condition: service_healthy
    networks:
      - chat-net

  db:
    image: mysql:8.4
    container_name: chat-db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    volumes:
      - db-data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-p${MYSQL_ROOT_PASSWORD}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - chat-net
    # Not exposed to the host on purpose — only the app service needs to reach it,
    # over the internal chat-net network. Uncomment for local DB debugging only:
    # ports:
    #   - "3306:3306"

networks:
  chat-net:
    driver: bridge

volumes:
  db-data:
    driver: local
EOF
```

Also  Create the `.env` files

```bash 
cat > ~/chat-app/.env.example << 'EOF'
# Copy this file to .env and fill in real values.
# .env is gitignored / dockerignored — never commit real secrets.

# --- App ---
APP_PORT=8080

# --- MySQL ---
MYSQL_ROOT_PASSWORD=change_me_root_password
MYSQL_DATABASE=chatdb
MYSQL_USER=chatapp
MYSQL_PASSWORD=change_me_app_password
EOF

cp ~/chat-app/.env.example ~/chat-app/.env

```
- Then edit `~/chat-app/.env` and replace the two `change_me_* ` placeholder passwords with real values of your choosing (any strings work for local testing):

- Yes. This docker-compose.yml is a two-service application stack:

```
                    Docker Compose
                         │
          ┌──────────────┴──────────────┐
          │                             │
          ▼                             ▼
     app service                   db service
     chat-app                      MySQL 8.4
          │                             │
          │        chat-net             │
          └───────────┬─────────────────┘
                      │
                Internal network
                      │
                 MySQL :3306
```
The app talks to MySQL using the service name `db`, and MySQL's data is persisted in the named volume `db-data`.

1. The cat command

```bash 
cat > ~/chat-app/docker-compose.yml << 'EOF'
```
This is the shell command , not Docker Compose syntax
It means -> Create/overwrite `~/chat-app/docker-compose.yml` and put everything I type until EOF into that file.

So after running it, we get:
```
~/chat-app/
├── Dockerfile
├── docker-compose.yml
├── main.go
├── go.mod
├── go.sum
├── index.html
└── history.html
```
The final:
```
EOF 
```
means: -> Stop Writing to the file 

2. `services`

```YAML
services: 
```
This is the most important section.
It defines the container that make up our application 

we have tw services 
```
services:
├── app
└── db
```
So Compose will create:
```
chat-app
chat-db
```

3. App service
```YAML
app:
```
- This is our GO Chat application 

Build the application
```YAML 
build:
  context: .
  dockerfile: Dockerfile
```
This tells Docker Compose: 

- Build the app image using the Dockerfile in the current directory.

`context: .`  -> The `.` Means-> current directory if we are inside `~/chat-app` -> then Docker uses: -> `~/chat-app` as a build context 

That's why our Dockerfile can do:
```dockerfile 
COPY main.go ./
COPY index.html history.html ./
```
- Because those files are inside build context 

`dockerfile: Dockerfile`

- Tells Compose which Dockerfile to use:
```bash 
~/chat-app/Dockerfile
```
So:
```
docker-compose.yml
       │
       ▼
Dockerfile
       │
       ▼
Build chat application image
```
4. Image name
```YAML 
image: chat-app:latest
```
- The image created by the build will be called: `chat-app:latest`

we can see it with:
```bash 
docker images 
```
we will see something like : 
```
REPOSITORY    TAG
chat-app      latest
```
- Important -> `latest` does not automatically mean "newest".
- It's simply a tag named `latest`.

OUTPUT: 


5. Container name

```YAML 
container_name: chat-app
```
Normally compose generates names such as: 
```
chat-app-app-1
```
But this explicitly tells Docker:
- Name my container `chat-app`. 

So:
```bash 
docker ps 
```
will show 
```
chat-app
```

6. Restart policy

```YAML 
restart: unless-stopped
```
This tells Docker:
- Automatically restart this container if it crashes or Docker restarts, unless I explicitly stopped it.

For example:
```
Application crashes
       │
       ▼
Docker restarts it
```
But if we manually do:
```bash 
docker compose stop app
```
- Docker won't continuously bring it back.

7. Port mapping

```YAML 
ports:
  - "${APP_PORT:-8080}:8080"
```

This maps : 
```
HOST {PORT } : CONTAINER {PORT}
```
so normally 
```
8080:8080
```
means:
```
Your computer
localhost:8080
      │
      ▼
Container
port 8080
```
we can access: 
```
http://localhost:8080
```

What does `${APP_PORT:-8080}` mean?

- This is Compose variable substitution : 
- It means Use `APP_PORT` if it exists; otherwise use `8080`. 

for example , if   `.env` conatains:
```
APP_PORT=9090
```
then compose creates: 
```
9090:8080
```
so: 
```
localhost:9090
       │
       ▼
container:8080
```
If `APP_PORT` isn't defined:
```
localhost:8080
       │
       ▼
container:8080
```
8. Environment variables for the app
```YAML
environment:
  APP_PORT: "8080"
  DB_HOST: db
  DB_PORT: "3306"
  DB_USER: ${MYSQL_USER}
  DB_PASSWORD: ${MYSQL_PASSWORD}
  DB_NAME: ${MYSQL_DATABASE}
```
These values are passed **inside the app container**
our GO application can read them using environment variables 

`APP_PORT`
```YAML 
APP_PORT: "8080"
```
our application knows it should use port:`8080`

`DB_HOST`
```YAML 
DB_HOST: db
```
This is extremely important 
we are not using -> `localhost` we are using   `db`
Why? -> Because `db` is the Compose service name.

Docker's internal DNS allows:
```
app → db
```
So our Go application can connect to: `db:3306`

Think of it like:
```
app container
     │
     │ DB_HOST=db
     ▼
Docker DNS
     │
     ▼
MySQL container
```

`DB_PORT`
```YAML 
DB_PORT: "3306"
```
MySQL's standard port is:`3306` so our application connects to `db:3306`


Database credentials
```YAML 
DB_USER: ${MYSQL_USER}
DB_PASSWORD: ${MYSQL_PASSWORD}
DB_NAME: ${MYSQL_DATABASE}
```
The values come form our  `.env` might contain:
```
MYSQL_USER=chatuser
MYSQL_PASSWORD=secret123
MYSQL_DATABASE=chatdb
```
Compose substitutes them.

The app effectively receives:
```
DB_USER=chatuser
DB_PASSWORD=secret123
DB_NAME=chatdb
```
9. `depends_on`
```YAML 
depends_on:
  db:
    condition: service_healthy
```
This establishes a startup dependency:
```bash 
db
 │
 │ must become healthy
 ▼
app
```
The important part is:
```
condition: service_healthy
```
- It doesn't merely wait for the MySQL container to start.

- It waits for the MySQL **healthcheck to succeed**.

10. Network
```YAML 
networks:
  - chat-net
 ```

The app is connected to:
```
chat-net 
```
The database is also connected to:
```
chat-net 
```
Therefore:
```
       chat-net
     /          \
    /            \
  app             db
  ```
They can communicate using their service names.

The app can connect to:
```
db:3306
```

11. Database service

Now:
```YAML 
db:
```
This defines our MySQL container.

12. MySQL image
```
image: mysql:8.4
```
- Instead of building your own MySQL image, Compose downloads the official MySQL image.

- we are specifically using `mysql:8.4` rather than `mysql:latest`
- That's better for predictable deployments.

13. Database container name

```YAML 
container_name: chat-db
```
The container will be called `chat-db` so : 
```bash 
docker ps 
```
might show
```
chat-app
chat-db
```

14. Database restart policy
```
restart: unless-stopped
```
Same idea as the app: If mysql crashes :
```
MySQL crashes
     │
     ▼
Docker restarts MySQL
```
unless you've explicitly stopped it.

15. MySQL environment variables
```YAML 
environment:
  MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
  MYSQL_DATABASE: ${MYSQL_DATABASE}
  MYSQL_USER: ${MYSQL_USER}
  MYSQL_PASSWORD: ${MYSQL_PASSWORD}
```
- These configure MySQL when the container is initialized.
For example:
```
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_DATABASE=chatdb
MYSQL_USER=chatuser
MYSQL_PASSWORD=secret123
```
MySQL will initialize:
```
Database:
chatdb

User:
chatuser

Password:
secret123

Root password:
rootpassword
```

16. Named volume
```YAML 
volumes:
  - db-data:/var/lib/mysql
```
This is extremely important for database persistence.
MySQL stores its data inside :
```
/var/lib/mysql #inside the container
```
we are mounting that dorectory to 
```
db-data
```
which is a Docker named volume.

So:
```
MySQL container
      │
      │ /var/lib/mysql
      ▼
┌─────────────────┐
│ db-data volume  │
└─────────────────┘
```
if we remove the mysql container: 
```bash
docker compose down 
```
the named volume normally remains 
Therefore our database data survives container recreation

17. MySQL healthcheck
```YAML 
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-p${MYSQL_ROOT_PASSWORD}"]
```
- This checks whether MySQL is actually responding.
- It's essentially asking: MySQL, are you alive and accepting connections?

- The command being executed is approximately:
```
mysqladmin ping -h localhost -u root -pPASSWORD
```
If MySQL responds successfully:
```
healthy 
```
If it doesn't:
```
unhealthy 
```

18. Healthcheck interval
```YAML 
interval: 10s
```
Docker checks MySQL every 10 sec:

19. Healthcheck timeout

```YAML 
timeout: 5s
```
Each check has up to: 5 seconds to respond 

20. Healthcheck retries

```YAML 
retries: 5
```
- MySql can fail ive checks before Docker consider it unhealthy 

21. Start period
```YAML 
start_period: 30s
```
- MYSQL can take some time to initialize.Docker gives it: 30s as a startup grace period 
- This is particularly useful for databases because they aren't always ready immediately after the container starts.

22. Database network
```YAML 
networks:
  - chat-net
```
- The MySQL container joins the same network as the app.

Therefore:
```
app
 │
 │ db:3306
 ▼
chat-net
 │
 ▼
db
```
23. Why isn't MySQL exposed?
we have
```YAML 
# ports:
#   - "3306:3306"
```
commented out.

That's intentional.The database doesn't need to be accessible directly from your laptop.The app is the only thing that needs MySQL.


So the architecture is:
```
Browser
   │
   │ localhost:8080
   ▼
┌─────────────┐
│     app     │
│   :8080     │
└──────┬──────┘
       │
       │ db:3306
       ▼
┌─────────────┐
│     db      │
│   MySQL     │
│    :3306    │
└─────────────┘
```
- The MySQL port is only available through the Docker network.
- That's a good security practice.
If you uncomment:
```YAML 
ports:
  - "3306:3306"
```
then our host could connect directly to MySQL:
```
localhost:3306
```
which is useful for debugging but isn't necessary for the application itself.

24. Explicit network definition

At the bottom:
```YAML
networks:
  chat-net:
    driver: bridge
```
we're creating a custom Docker bridge network called:
```
chat-net
```
Docker creates it when you run:
```
docker compose up
```
we can check it with:
```bash 
docker network ls
```
we will see something similar to:
```
NETWORK ID     NAME
xxxxxxx        chat-net
```

25. Why use a custom network?
Because both services need to communicate: 

```
app ←──── chat-net ────→ db
```
Docker provides internal DNS 
so : 
```
DB_HOST=db
```
works automatically.
we don't need to find the MySQL container's IP address.

That's one of the biggest benefits of Docker Compose networking.

26. Define the named volume

At the bottom:
```YAML 
volumes:
  db-data:
    driver: local
```
This creates a Docker named volume:
```
db-data
```
using Docker's local volume driver.

Check it with:
```bash 
docker volume ls 
```
we should see something similar to 
```
DRIVER    VOLUME NAME
local     chat-app_db-data
```
Compose may prefix the volume with the project name.

#### Complete Architecture
```
                    HOST MACHINE
                         │
                         │ localhost:8080
                         ▼
                ┌─────────────────┐
                │   chat-app      │
                │                 │
                │   Go Server     │
                │   :8080         │
                └────────┬────────┘
                         │
                         │ db:3306
                         │
                 ┌───────▼───────┐
                 │   chat-net    │
                 │ bridge network│
                 └───────┬───────┘
                         │
                         ▼
                ┌─────────────────┐
                │    chat-db      │
                │                 │
                │   MySQL 8.4     │
                │   :3306         │
                └────────┬────────┘
                         │
                         │ /var/lib/mysql
                         ▼
                ┌─────────────────┐
                │    db-data      │
                │  Docker Volume  │
                └─────────────────┘

```
The startup sequence

when we run :
```bash 
docker compose up 
```
the flow is 
```
docker compose up
       │
       ▼
Create chat-net
       │
       ▼
Create db-data
       │
       ▼
Start MySQL
       │
       ▼
MySQL initializes
       │
       ▼
Healthcheck runs
       │
       ├── unhealthy → wait/retry
       │
       └── healthy
              │
              ▼
         Start app
              │
              ▼
      app connects to db:3306
              │
              ▼
        Chat application ready
  ```

#### The 3 most important things to understand

1. `depends_on + service_healthy` -> the app waits for MySQL to actually become healthy.
2. `DB_HOST: db` -> he app reaches MySQL using the Compose service name, not an IP address.
3. `db-data:/var/lib/mysql` -> MySQL data survives container recreation.

This is a very good example of the Docker concepts you've been learning: **custom networks + named volumes + healthchecks + `depends_on` + environment variables + multi-stage application image**.

 