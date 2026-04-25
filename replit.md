# Pkmnditto

A Rails 8.1 application that wraps the public PokeAPI (https://pokeapi.co) and
manages local `Type` and `Item` resources. Uses Hotwire (Turbo + Stimulus) and
the Propshaft asset pipeline.

## Tech Stack

- Ruby 3.2 / Rails 8.1.3
- SQLite 3 (development, test, and production via the `storage/` directory)
- Puma web server
- Importmap + Turbo + Stimulus (Hotwire)
- Solid Cache / Solid Queue / Solid Cable
- HTTParty + dotenv-rails (PokeAPI integration)

## Project Layout

- `app/controllers/types_controller.rb` — CRUD for `Type` records
- `app/controllers/items_controller.rb` — CRUD for `Item` records (no route mounted)
- `app/helpers/pokemon_helper.rb` — Wraps the public PokeAPI; reads endpoint URLs from env vars
- `config/routes.rb` — Mounts `resources :types`, root → `types#index`, and `/up` health check
- `db/migrate/` — Schemas for `pokemon`, `items`, and `types`

## Environment Variables

The PokeAPI helper reads these from the environment (configured in Replit Secrets):

- `PKMN_ENDPOINT` — `https://pokeapi.co/api/v2/pokemon/`
- `TYPE_ENDPOINT` — `https://pokeapi.co/api/v2/type/`
- `DEFAULT_PKMN` — default Pokémon name (`jynx`)
- `DEFAULT_PKMN_ID` — default Pokémon id (`124`)
- `DEFAULT_PKMN_TYPE` — default type (`ice`)
- `DEFAULT_PKMN_URL` — full URL to the default Pokémon resource

## Replit Setup Notes

- The workflow `Start application` runs:
  `env -u DATABASE_URL bundle exec rails server -b 0.0.0.0 -p 5000`
- `DATABASE_URL` is unset because Replit injects a Postgres URL by default,
  but this project is configured for SQLite in `config/database.yml`.
- `config/environments/development.rb` clears `config.hosts` and bypasses
  `host_authorization` so the Replit iframe preview (which proxies a
  `*.replit.dev` host) can reach the dev server.
- System dependency `libyaml` is installed via Nix (required by the `psych` gem).

## Running Locally

```bash
env -u DATABASE_URL bundle exec rails db:migrate
env -u DATABASE_URL bundle exec rails server -b 0.0.0.0 -p 5000
```

Visit `/` for the Types index, `/types/new` to create one, and `/up` for the
health check.

## Deployment

Configured for VM deployment (SQLite needs persistent disk):

- Build: `bundle install --deployment --without development test`
- Run: migrates the production database then starts Puma on port 5000
- A `RAILS_MASTER_KEY` secret must be set to decrypt
  `config/credentials.yml.enc` in production.
