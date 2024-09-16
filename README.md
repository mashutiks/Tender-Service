
# Tender-Service

[](https://github.com/mashutiks/Tender-Service/blob/main/README.md#tender-service)

This project provides a web application for managing tenders and proposals using FastAPI and PostgreSQL, containerized with Docker. 
The application includes functionality for creating, editing, canceling, and rolling back versions of tenders and proposals, as well as publishing and viewing reviews for proposals. The backend is written in Python. 

>Note: Before creating a tender, you must first create an organization:
```bash
@app.post("/api/organizations/new")
```

## Table of Contents

[](https://github.com/mashutiks/Tender-Service/blob/main/README.md#table-of-contents)

-   [Installation](https://github.com/mashutiks/Tender-Service/blob/main/README.md#installation)
-   [Running](https://github.com/mashutiks/Tender-Service/blob/main/README.md#running)
-   [Technologies Used](https://github.com/mashutiks/Tender-Service/blob/main/README.md#technologies-used)

## Installation

[](https://github.com/mashutiks/Tender-Service/blob/main/README.md#installation)

### 1. Clone the repository

[](https://github.com/mashutiks/Tender-Service/blob/main/README.md#1-clone-the-repository)

git clone https://github.com/mashutiks/Tender-Service.git
cd Tender-Service/app

### 2. Install dependencies
Ensure that Docker and Docker Compose are installed. If not, you can install them from the official Docker website.

### 3. Run Docker Engine
Make sure Docker Engine is running.

### 4. Build and run containers
Build and run the containers using Docker Compose:

```bash
docker-compose up --build
docker-compose up
```

This will create and start the containers for your application and database.

### Running
Once the containers are up and running, your web application will be available at: http://localhost:8080

### Technologies Used
- **FastAPI**: Web framework for building the backend.
- **PostgreSQL**: Database for storing tenders and proposals.
- **Docker**: Used for containerizing the application and PostgreSQL.
- **Python**: Programming language used to implement the backend.
