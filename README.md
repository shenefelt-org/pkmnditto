# PKMNDITTO

Rails 8 app with SQLite, packaged for Docker runtime.

## 1) Build The App Image

From the project root:

```bash
docker build -t pkmnditto:latest .
```

The repository scripts can also tag and push `ghcr.io/shenefelt-org/pkmnditto:latest`, but `docker pull` will only work if that GHCR package has actually been published and your client has access to it.

```powershell copy
docker build -t pkmnditto:latest .
$env:SECRET_KEY_BASE = (Get-Content .env | Select-String "^SECRET_KEY_BASE=").ToString().Split("=")[1]
```

## 2) Run Locally In Docker (Client Machine)

The app needs RAILS_MASTER_KEY at runtime.

If you built the image locally, run `pkmnditto:latest`.
If you want to pull from GHCR instead, publish the package first or authenticate with `docker login ghcr.io` and then use `ghcr.io/shenefelt-org/pkmnditto:latest`.

### PowerShell example

## Run the app

```powershell copy
$env:SECRET_KEY_BASE = (Get-Content C:\app-path\.env | Select-String '^SECRET_KEY_BASE=').ToString().Split('=')[1]

docker run --rm --name pkmnditto-test -p 3000:80 `
  -e SECRET_KEY_BASE=$env:SECRET_KEY_BASE `
  -e RAILS_ENV=production `
  -v pkmnditto_storage:/rails/storage `
  pkmnditto:latest
```

Open <http://localhost:3000>
