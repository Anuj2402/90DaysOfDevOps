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


# Task 5: Validate Your YAML

we currently have two files: 
- `person.yaml`
- `server.yaml`

Let's validate both properly 

### step-01: Install `yamllint`
On Ubuntu/Debian:
```bash 
sudo apt update
sudo apt install yamllint -y
```
Verify:
```bash 
yamllint --version
```
we should get something like 
```
yamllint 1.x.x
```

### Step 2: Validate `person.yaml`

RUN: 
```bash 
yamllint person.yaml
```
- If everything is clean, we may see no output, or you may see style warnings depending on the default `yamllint` configuration.

To check syntax only; use : 
```bash 
yamllint -d relaxed person.yaml
```

### Step 3: Validate server.yaml
```bash 
yamllint -d relaxed server.yaml
```
Again, no output means the YAML passes the relaxed validation rules. 

we can also validate both together:
```bash 
yamllint -d relaxed person.yaml server.yaml
```

### Step 4: Intentionally break indentation

First make a backup:
```bash 
cp server.yaml server.yaml.backup
```
Now edit the file:

```bash 
vi server.yaml 
```
chnage this 
```YAML 
database:
  host: localhost
  name: chatdb
```
to something incorrectly indented, for example:
```YAML 
database:
  host: localhost
 name: chatdb
```

### Step 5: Validate the broken YAML
RUN: 
```bash 
yamllint -d relaxed server.yaml
```
we should get an error similar to 
```
server.yaml
  7:2       error    wrong indentation: expected 2 but found 1  (indentation)

```
- The exact line/column and wording can vary depending on where you broke the indentation.


### Step 6: Fix it
Change it back to:
```YAML 
database:
  host: localhost
  name: chatdb

```

Then run:
```bash 
yamllint -d relaxed server.yaml
```
If there is no output , we are good 

### Step 7: Final validation
RUN: 
```bash 
yamllint -d relaxed person.yaml server.yaml
```


### Notes

YAML indentation is significant. Incorrect indentation can cause a YAML parsing or indentation error. YAML uses spaces for indentation; tabs should not be used.