# Task 1: Install and Configure Git

Q1-> Verify Git is installed on your machine

Command we will use to verify that is below : 
```bash 
git --version 
```
output: 
```
anujrai@anujrai-mn4561 90DaysOfDevOps % git --version 
git version 2.50.1 (Apple Git-155)
anujrai@anujrai-mn4561 90DaysOfDevOps % 
```

### Q2-> Set up your Git identity — name and email: 
- To set up your Git identity (username and email), run these commands in your terminal:

Set Username:
```bash 
git config --global user.name "Your Name"

```
Set Email:
```bash 
git config --global user.email "your.email@example.com"
```

Q3-> Verify Configuration:
- Check that the values were saved:
```bash 
git config --global user.name
git config --global user.email
```
Or view all Git configuration:
```bash 
git config --global --list

```
### Understanding --global
- **--global** → applies to all Git repositories for your user account.
- Without **--global**, the setting applies only to the current repository.

To check where Git is reading the configuration from:
```bash
git config --list --show-origin
```

