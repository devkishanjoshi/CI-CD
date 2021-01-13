# CI/CD Pipeline

CI/CD pipeline for a NodeJS app.

## Getting Started
```
This will give you a basic idea about a nodejs ci/cd Pipeline.
```
### Prerequisites
```

* The Jenkins, Sonarqube and k8s cluster needs to be up 
[https://github.com/devkishanJoshi/DevOps/tree/master/Jenkins-Sonarqube](Use the following to setup if not)
* Provision a Postgres DB: Must be reachable from your cluster and Sonarqube instance
```
### Installing

1. Download the require plugins in Jenkins:
```
* SonarQube Scanner
* Kubernetes CLI
* Gitlab Hook Plugin
* CloudBees Docker Build and Publish
* Docker Pipeline
* NodeJS
* Email Extension
```

2. Store the required credentials in jenkins *Manage Credentials*: 
```
* Github (Username with password)
* Sonarqube  (Secret text): Login token generate on sonarqube 
* Docker Hub (Username with password)
* Kubernetes (Secret file):  .kube/config file  
```


3. Create webhook in your Git repository hosting service:
```
Create a webhook so that when you push code to the respective branch (Master) in our case your code will be deployed to the cluster
```

4. Create a job in jenkins:
```
* Pipeline File: ./Jenkinsfile
* Dockerfile for NodeJS app: ./Dockerfile
* Files related to  NodeJS app: ./package.json, ./server.js, and ./test/*
```

Technology Stack used: 
```
* Git/GitHub  (Developer push code to gitHub -> Triggers the Job in Jenkins)
* Jenkins (The Job use the Jenkinsfile present)
* Sonarqube (Checks the code as per the rules and Quality Gate will tells whether the code is ready to deploy)
* Docker (Builds image and Push it to DockerHub)
* Kubernetes (The app Deployment as per files present in k8s folder)
```