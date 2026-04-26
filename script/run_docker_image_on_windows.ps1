$env:SECRET_KEY_BASE = (Get-Content C:\laragon\www\pkmnditto\.env | Select-String '^SECRET_KEY_BASE=').ToString().Split('=')[1]

docker run --rm --name pkmnditto-test -p 3000:80 `
  -e SECRET_KEY_BASE=$env:SECRET_KEY_BASE `
  -e RAILS_ENV=production `
  -v pkmnditto_storage:/rails/storage `
  pkmnditto:latest