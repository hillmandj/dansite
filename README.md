# daniel-hillman.com

Personal site: an about page, a portfolio of projects, and a small Textile blog with an admin editor.

- **Stack:** Ruby 4.0, Rails 8.1, SQLite, Haml, Devise (single admin user)
- **Runs as:** a Docker container behind kamal-proxy on one DigitalOcean droplet ([infra/README.md](infra/README.md))
- **Deploys with:** [Kamal](https://kamal-deploy.org), from GitHub Actions or locally

## Development

You only need Docker. Ruby runs inside the container.

```bash
docker compose up                              # http://localhost:3000
docker compose run --rm web bin/rails db:seed  # sample projects/posts + admin@example.com / password123
docker compose run --rm web bundle exec rspec  # tests
docker compose run --rm web bin/rubocop        # lint
docker compose run --rm web bin/brakeman       # security scan
docker compose run --rm web bin/rails console
```

The dev database is `storage/development.sqlite3`, which is gitignored. To work against
real content, copy a production backup there and run
`docker compose run --rm web bin/rails db:environment:set RAILS_ENV=development`.

## Secrets

- `config/master.key` decrypts `config/credentials.yml.enc`. It is gitignored. Keep a copy
  in your password manager and in the `RAILS_MASTER_KEY` GitHub Actions secret.

## Deploying

Pushing to `master` runs CI (tests, RuboCop, Brakeman, bundler-audit). To deploy, run the
**Deploy** workflow from the Actions tab. It builds the image, pushes it to `ghcr.io`, and runs
`kamal deploy`, which starts the new container and switches traffic once `/up` responds.

To deploy from your machine instead:

```bash
export KAMAL_REGISTRY_PASSWORD=<GitHub token with write:packages>
bin/kamal deploy
```

Useful commands: `bin/kamal logs`, `bin/kamal console`, `bin/kamal app details`, `bin/kamal rollback <version>`.

### GitHub repository setup (one time)

Settings → Secrets and variables → Actions:

| Secret            | Value |
|-------------------|-------|
| `RAILS_MASTER_KEY` | contents of `config/master.key` |
| `DEPLOY_SSH_KEY`   | private key whose public half is in `deploy`'s `authorized_keys` on the droplet |

`GITHUB_TOKEN` is used to push to ghcr.io and needs no setup.

## Database

SQLite at `/rails/storage/production.sqlite3` in the `dansite_storage` Docker volume on the
droplet. Migrations run automatically when the container boots (`bin/docker-entrypoint` → `db:prepare`).
