# How to Run Color-Sync

This guide provides simple steps to run the **Color-Sync-Github-Actions** project on your local machine.

There are two primary ways to run this project:
1. Using Node.js directly
2. Using Docker

---

## Method 1: Running with Node.js directly

Prerequisites: You must have **Node.js** and **npm** installed on your system.

### Steps:
1. **Open your terminal** and navigate to the project directory:
   ```bash
   cd /path/to/Color-Sync-Github-Actions
   ```

2. **Install the dependencies**:
   ```bash
   npm install
   ```

3. **Start the application**:
   ```bash
   node app.js
   ```

4. **Access the web app**:
   Open your web browser and navigate to:
   [http://localhost:3000](http://localhost:3000)

---

## Method 2: Running with Docker

Prerequisites: You must have **Docker** installed and running on your system.

### Steps:
1. **Open your terminal** and navigate to the project directory:
   ```bash
   cd /path/to/Color-Sync-Github-Actions
   ```

2. **Build the Docker Image**:
   This packages the application into a Docker container.
   ```bash
   docker build -t color-sync .
   ```

3. **Run the Docker Container**:
   This command starts the container and maps port `3000` (or your preferred port) on your machine to the port `3000` inside the container.
   ```bash
   docker run -d -p 3000:3000 --name color-sync-app color-sync
   ```

4. **Access the web app**:
   Open your web browser and navigate to:
   [http://localhost:3000](http://localhost:3000)

*(Note: If you want to stop the Docker container later, run `docker stop color-sync-app`)*
