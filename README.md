# daniel-hillman.com

My personal site: an about page, a portfolio of projects, and a small blog I write from a
private admin page.

It's a Rails app with a SQLite database. It runs in Docker on a single DigitalOcean server,
and HTTPS certificates are renewed automatically. Server details are in
[infra/README.md](infra/README.md).

## Running it locally

You only need Docker installed.

```bash
docker compose up                              # then open http://localhost:3000
docker compose run --rm web bin/rails db:seed  # adds sample content and a login: admin@example.com / password123
docker compose run --rm web bundle exec rspec  # run the tests
docker compose run --rm web bin/rails console  # Rails console
```

Your local data lives in `storage/development.sqlite3` and is never committed. To work
with real content, copy a production backup to that path, then run
`docker compose run --rm web bin/rails db:environment:set RAILS_ENV=development`.

## The master key

`config/master.key` unlocks the app's encrypted settings (`config/credentials.yml.enc`).
It is never committed, so keep a copy in your password manager. GitHub has a copy too, as
the `RAILS_MASTER_KEY` secret. If you lose it, you'll need to create new credentials.

## Deploying

### Normally: from GitHub

1. Push or merge to `master`. GitHub runs the tests and checks automatically.
2. Go to **Actions → Deploy → Run workflow**.

The new version starts alongside the old one, and traffic switches over only once it's
healthy. If the new version fails to start, the old one keeps running.

### If GitHub Actions is down: from your machine

One-time setup:

```bash
rbenv install 4.0.9                # the Ruby version this app uses
bundle install                     # installs Kamal, the deploy tool
gh auth refresh -s write:packages  # lets your gh login push images to GitHub's registry
```

Also make sure `config/master.key` exists and `ssh deploy@152.42.155.192` works.

To deploy:

```bash
export KAMAL_REGISTRY_PASSWORD=$(gh auth token)
bin/kamal deploy
```

This builds the site on your machine, uploads it to GitHub's image registry, and switches the
server over to it. This is exactly what the GitHub workflow does.

Other useful commands:

| Command | What it does |
|---|---|
| `bin/kamal logs` | show the live server logs |
| `bin/kamal console` | open a Rails console on the server |
| `bin/kamal app details` | show what's running |
| `bin/kamal rollback <version>` | go back to an earlier version (the version is a commit SHA) |

### GitHub secrets

These are already set up, under **Settings → Secrets and variables → Actions**. You'd only
need to touch them if you rotate a key.

| Secret | What it is |
|---|---|
| `RAILS_MASTER_KEY` | the contents of `config/master.key` |
| `DEPLOY_SSH_KEY` | the private key GitHub uses to log in to the server as `deploy` |

## The database

Production uses SQLite. The database file lives on the server in a Docker volume (a folder
Docker manages that survives redeploys). Database changes run automatically each time a new
version starts. To back it up or restore it, see [infra/README.md](infra/README.md).
