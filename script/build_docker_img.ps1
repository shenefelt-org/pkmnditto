docker build -t pkmnditto:latest .
$env:SECRET_KEY_BASE = (Get-Content .env | Select-String "^SECRET_KEY_BASE=").ToString().Split("=")[1]