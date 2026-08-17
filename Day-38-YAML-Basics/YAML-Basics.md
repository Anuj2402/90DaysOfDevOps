# Task 1: Key-Value Pairs

### Step-1 -> Create a file called `Person.YAML`

```bash 
vi person.YAML 
```

```YAML

name: Anuj 
role: DevOps Engineer
Experience_Years: 2.5
learning: true 

```
OUTPUT: 

![alt text](image.png)

Our YAML is clean because: 
- `name` -> string 
- `role` -> String 
- `experience_years` -> number 
- `learning` -> boolean ( `true` , not `true`)

# Task 2: Lists

#### Step-01: Update `person.yaml`
Replace the file with: 
```YAML 
name: Anuj
role: DevOps Engineer
experience_years: 1.7
learning: true

tools:
  - Docker
  - Kubernetes
  - Terraform
  - Git
  - Jenkins

hobbies: [Learning, Troubleshooting, Cricket]
```

#### Step 2: Verify

```bash
cat person.yaml
```

OUTPUT: 
![alt text](image-1.png)

#### Notes: Two ways to write a list in YAML

1. Block style / multi line : 
```YAML 
tools: 
  - Docker 
  - kubernetes 
  - Terraform 

2. Inline / flow style: 

```YAML 
hobbies: [Learning, Troubleshooting, Cricket]
```
YAML supports lists in two ways: block-style lists using` - `on separate lines, and inline/flow-style lists using `[ ]`.


# Task 3: Nested Objects

### step-01 Create `server.yaml`

RUN:
```YAML 
server: 
  name: chat-server
  ip: 192.168.1.10
  port: 8080


database: 
  host: localhost
  name: chatdb
  credentials:
    user: admin
    password: secret123

```
### step-02 Verify the file
```bash 
cat server.yaml
```

OUTPUT: 



Notice how spaces create the nesting:
```
database
└── credentials
    ├── user
    └── password
```

### Step 3: Validate the YAML
If we have Python installed:
```bash 
python3 -c "import yaml; yaml.safe_load(open('server.yaml')); print('Valid YAML')"
```

we wil get an error similar to : 
```
yaml.scanner.ScannerError: while scanning for the next token
found character '\t' that cannot start any token
```
#### What to note

**YAML does not allow tabs for indentation**. Use spaces only. A tab can cause the YAML parser/validator to reject the file.


# Task 4: Multi-line Strings
we will add two fields to `server.yaml` so we can see the difference between `|` and `>`

#### Step 1: Edit `server.yaml`
RUN: 
```YAML 
cat >> server.yaml <<'EOF'

startup_script_literal: |
  #!/bin/bash
  echo "Starting server"
  systemctl start nginx
  echo "Server started"

startup_script_folded: >
  #!/bin/bash
  echo "Starting server"
  systemctl start nginx
  echo "Server started"
EOF
```
#### Step 2: Verify

```bash 
cat server.yaml
```
we should see : 
```YAML 
server:
  name: chat-server
  ip: 192.168.1.10
  port: 8080

database:
  host: localhost
  name: chatdb
  credentials:
    user: admin
    password: secret123

startup_script_literal: |
  #!/bin/bash
  echo "Starting server"
  systemctl start nginx
  echo "Server started"

startup_script_folded: >
  #!/bin/bash
  echo "Starting server"
  systemctl start nginx
  echo "Server started"

```

#### Step 3: Understand the difference

`|` — Literal/block style

Preserves the line breaks:
```YAML 
script: |
  line 1
  line 2
  line 3

```

Result is essentially:
```
line 1
line 2
line 3
```
Use `|` when newlines matter, especially for:

- shell scripts 
- configuration files 
- SQL 
- certificates 
- multi- line commands 

`>` — Fold style
Folds the separate lines into a single line:

```YAML 
message: >
  line 1
  line 2
  line 3
```
Result is essentially:

```
line 1 line 2 line 3
```
Use `>` when you want to write long text across multiple YAML lines but don't want those line breaks preserved.

#### Notes
`|` -> preserves newlines; use it when formatting/line breaks are important, such as scripts.

`>` -> folds newlines into spaces; use it for long text or values that should ultimately be treated as one line.

Quick memory trick

`|` = "keep the lines"
`>` = "join/fold the lines"
