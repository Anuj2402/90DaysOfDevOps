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