# Task 1: The Problem

Think about a team of 5 developers all pushing code to the same repo manually deploying to production.

1. What can go wrong?

If 5 developers are manually pushing code and deploying to production
- **Human errors** — someone can deploy the wrong version or wrong configuration.

- **Code conflicts** — developers may overwrite or break each other's changes.
- **Broken builds** — code may work locally but fail in production.
- **No consistent testing** — code can reach production without proper tests.
- **Downtime** — a bad deployment can take the application down.
- **Rollback problems** — manually identifying and restoring the previous working version takes time.
- **Configuration mistakes** — production environment variables, dependencies, or settings may differ.
- **No deployment traceability** — it becomes difficult to know who deployed what and when.
- **Slow releases** — developers have to coordinate deployments manually.


2. What does "It works on my machine" mean?

"It works on my machine" means the application works correctly in a developer's local environment but fails somewhere else, such as staging or production.

For example:
```
Developer laptop
├── Python 3.12
├── Package version 1.5
├── Environment variable available
└── Code works ✅

Production
├── Python 3.10
├── Package version 1.3
├── Environment variable missing
└── Application fails ❌
```
This is a real problem because different environments can have different operating systems, dependency versions, configurations, environment variables, and runtime versions.

CI/CD helps solve this by automatically building and testing the application in a consistent, repeatable environment before deployment.

3. How many times a day can a team safely deploy manually?

There is no fixed safe number.

For a 5-person team, manually deploying once or twice a day might be manageable, but as deployment frequency increases, the chance of human error and coordination problems also increases.

The bigger lesson is:

Manual deployment doesn't scale well.
With CI/CD, deployments can happen many times per day because testing, building, validation, and deployment are automated.

Key takeaway
```
Manual Process:
Developer → Manual Build → Manual Test → Manual Deploy → Production
                         ↑
                    Human errors

CI/CD:
Developer → Git Push → Build → Test → Deploy → Production
                       🤖      🤖       🤖
                     Automated
```
CI/CD exists largely to make software delivery faster, safer, repeatable, and less dependent on manual work.

# Task 2: CI vs CD

1. Continuous Integration (CI)

Definition: 
Continuous Integration means developers frequently merge/push their code into a shared repository. Every change automatically triggers builds and automated tests to catch bugs, integration issues, and broken code early.

How often: Multiple times per day, whenever developers push/merge code.

Real-world example:
A developer pushes code to GitHub → GitHub Actions automatically runs the application build and unit tests → if tests fail, the developer is notified before the code is merged.


2. Continuous Delivery (CD)

Definition:
Continuous Delivery builds on CI by automatically preparing tested and validated code for release. The application is always kept in a deployable state, but the actual production deployment usually requires a manual approval.

How it's different from CI:
CI focuses mainly on integrating, building, and testing code. Continuous Delivery takes that validated code further and prepares it for release/deployment.

Real-world example:
Developer pushes code → CI runs tests → Docker image is built → image is pushed to a container registry → staging is deployed → production deployment waits for a manager/engineer to approve it.

3. Continuous Deployment

Definition:
Continuous Deployment goes one step beyond Continuous Delivery: every change that successfully passes the automated pipeline is automatically deployed to production, without a manual approval step.

How it differs from Delivery:
```
Continuous Delivery:
Code → Build → Test → Staging → [Manual Approval] → Production

Continuous Deployment:
Code → Build → Test → Staging → Production
                              ↑
                         Automatically
```
When teams use it:
Teams use Continuous Deployment when they have strong automated testing, monitoring, rollback mechanisms, and confidence in their deployment pipeline.

Real-world example:
A developer merges a tested feature → GitHub Actions builds the Docker image → runs tests/security checks → deploys it to Kubernetes → users immediately receive the new version.

Easy way to remember

CI = Integrate + Test

Continuous Delivery = Integrate + Test + Ready to Deploy

Continuous Deployment = Integrate + Test + Automatically Deploy

