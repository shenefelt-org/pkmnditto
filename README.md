# PkmnDitto

A Ruby on Rails application for working with Pokémon data.

## Ruby Version

Ruby **3.2.3** (see `.ruby-version`)

## System Dependencies

- Ruby 3.2.3
- SQLite3
- libvips (for image processing)
- Node.js (for asset management via importmap)

## Configuration

No additional environment configuration is required for development. For production, set:

- `RAILS_MASTER_KEY` — value from `config/master.key` (do not commit this file)

## Database Creation

```bash
bin/rails db:create
```

## Database Initialization

```bash
bin/rails db:migrate
bin/rails db:seed
```

Or do all of the above in one step:

```bash
bin/rails db:setup
```

## Running the Application

```bash
bin/rails server
```

The app will be available at `http://localhost:3000`. A health check endpoint is available at `/up`.

## Running the Test Suite

Prepare the test database and run all tests:

```bash
bin/rails db:test:prepare test
```

Run system tests:

```bash
bin/rails db:test:prepare test:system
```

## Code Quality

Run the linter:

```bash
bin/rubocop
```

Run static security analysis:

```bash
bin/brakeman --no-pager
bin/bundler-audit
bin/importmap audit
```

## Services

The following background services are bundled via [Solid](https://github.com/rails/solid_queue):

| Service | Purpose |
|---|---|
| solid_queue | Background job processing |
| solid_cache | Database-backed caching |
| solid_cable | Action Cable via the database |

## Deployment

### Docker

Build and run the production Docker image:

```bash
docker build -t pkmnditto .
docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name pkmnditto pkmnditto
```

The container entrypoint automatically runs `db:prepare` on startup.

### Kamal

This application is configured for deployment with [Kamal](https://kamal-deploy.org). See `.kamal/` for deployment secrets configuration.

```bash
kamal setup    # first-time deploy
kamal deploy   # subsequent deploys
```
