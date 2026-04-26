# PKMNDITTO

Rails 8 app with SQLite, packaged for Docker runtime.

## 1) Build The App Image

From the project root:

```bash
docker build -t pkmnditto:latest .
```

## 2) Run Locally In Docker (Client Machine)

The app needs RAILS_MASTER_KEY at runtime.

### PowerShell example

```powershell
$env:SECRET_KEY_BASE = (Get-Content .env | Select-String SECRET_KEY_BASE).ToString().Split('=')[1]
docker run --rm -p 3000:80 -e SECRET_KEY_BASE=$env:SECRET_KEY_BASE -e RAILS_ENV=production -v pkmnditto_storage:/rails/storage --name pkmnditto pkmnditto:latest
```

Open <http://localhost:3000>

Notes:

- bin/docker-entrypoint automatically runs db:prepare when the server starts.
- SQLite production files are kept in /rails/storage and persisted with a Docker volume.

## 3) Docker Setup On Client Machine (Windows)

Use this for local build and testing.

1. Enable virtualization in BIOS or UEFI.
2. Install Docker Desktop for Windows.
3. Enable WSL 2 integration during install.
4. In Docker Desktop settings, enable WSL 2 based engine and distro integration.
5. Verify install:

```powershell
docker --version
docker compose version
docker run --rm hello-world
```

## 4) Docker Setup On Host Machine (Ubuntu Linux)

Use this for production deployment.

### Install Docker Engine and Compose plugin

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
newgrp docker
docker --version
docker compose version
docker run --rm hello-world
```

### Allow inbound web traffic

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw status
```

## 5) Deploy To Host From Built Image

Use Docker Hub or GHCR. Example flow:

### On client machine (build and push)

```bash
docker tag pkmnditto:latest your-dockerhub-user/pkmnditto:latest
docker push your-dockerhub-user/pkmnditto:latest
```

### On host machine (pull and run)

```bash
docker pull your-dockerhub-user/pkmnditto:latest
docker volume create pkmnditto_storage
docker run -d --name pkmnditto --restart unless-stopped -p 80:80 -e RAILS_ENV=production -e SECRET_KEY_BASE="paste-value-from-env-file" -v pkmnditto_storage:/rails/storage your-dockerhub-user/pkmnditto:latest
```

## 6) Useful Operations

```bash
docker logs -f pkmnditto
docker exec -it pkmnditto ./bin/rails db:migrate
docker exec -it pkmnditto ./bin/rails runner "puts Pokemon.count"
docker stop pkmnditto
docker rm pkmnditto
```

## 7) Data Backup (SQLite Volume)

```bash
docker run --rm -v pkmnditto_storage:/volume -v $(pwd):/backup alpine tar czf /backup/pkmnditto_storage_backup.tgz -C /volume .
```
