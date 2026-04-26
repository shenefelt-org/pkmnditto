${repoUrl} = "https://github.com/shenefelt-org/pkmnditto"
${revision} = (git rev-parse --short=12 HEAD).Trim()
${created} = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
${version} = ${revision}

docker build `
	--build-arg IMAGE_SOURCE=${repoUrl} `
	--build-arg IMAGE_URL=${repoUrl} `
	--build-arg IMAGE_REVISION=${revision} `
	--build-arg IMAGE_CREATED=${created} `
	--build-arg IMAGE_VERSION=${version} `
	-t pkmnditto:latest `
	-t ghcr.io/shenefelt-org/pkmnditto:latest `
	.

if ($LASTEXITCODE -ne 0) {
    Write-Error "docker build failed — skipping push"
    exit 1
}

Write-Host "Pushing ghcr.io/shenefelt-org/pkmnditto:latest ..."
docker push ghcr.io/shenefelt-org/pkmnditto:latest

if ($LASTEXITCODE -eq 0) {
    Write-Host "Push succeeded. Revision: ${revision}"
} else {
    Write-Error "docker push failed"
    exit 1
}

$env:SECRET_KEY_BASE = (Get-Content .env | Select-String "^SECRET_KEY_BASE=").ToString().Split("=")[1]
