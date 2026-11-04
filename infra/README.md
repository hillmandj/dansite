# Infrastructure

The site runs on a single DigitalOcean droplet. Kamal deploys the app as Docker
containers. SQLite lives in a Docker volume on the droplet.

## Resources (DigitalOcean, region `nyc3`)

| Resource      | Name / value                         | Cost        |
|---------------|--------------------------------------|-------------|
| Droplet       | `dansite` (`s-1vcpu-1gb`, Ubuntu 26.04 LTS), tag `dansite` | $6/mo |
| Reserved IP   | `152.42.155.192` → `dansite`         | free while attached |
| Cloud Firewall| `dansite-web` (applies to tag `dansite`): in 22/80/443 + ICMP, out all | free |
| SSH key       | `dansite-ed25519` (`~/.ssh/id_ed25519.pub`) | free |
| DNS           | `daniel-hillman.com` zone (A `@`, CNAME `www` → `@`) | free |

Point DNS at the **reserved IP**, never at the droplet's own IP. Then the droplet
can be rebuilt or replaced by moving the reserved IP, with no DNS change.

## Access

```bash
ssh dan@152.42.155.192      # admin, passwordless sudo
ssh deploy@152.42.155.192   # Kamal deploy user (docker group, no sudo)
```

Root login and password auth are disabled. Users log in with SSH keys only.

## Recreating the droplet

First-boot configuration is in [`cloud-init.yaml`](cloud-init.yaml). It sets up the
users, SSH hardening, Docker, swap and unattended upgrades.

```bash
doctl compute droplet create dansite \
  --region nyc3 --size s-1vcpu-1gb --image ubuntu-26-04-x64 \
  --ssh-keys <dansite-ed25519 key ID> \
  --user-data-file infra/cloud-init.yaml \
  --enable-monitoring --enable-ipv6 --tag-name dansite --wait

# Move the reserved IP to the new droplet
doctl compute reserved-ip-action assign 152.42.155.192 <new droplet ID>
```

The firewall applies by tag, so a new droplet tagged `dansite` is covered automatically.
After that, restore `production.sqlite3` into the app's volume and run a Kamal deploy.

## Cutover runbook

Each step can be undone until step 6. The live site keeps running on the legacy
droplet until DNS changes in step 6.

### 1. One-time setup

```bash
# Key GitHub Actions uses to SSH in as `deploy`
ssh-keygen -t ed25519 -N "" -C "github-actions-deploy" -f ~/.ssh/dansite_deploy
ssh dan@152.42.155.192 "echo '$(cat ~/.ssh/dansite_deploy.pub)' | sudo tee -a /home/deploy/.ssh/authorized_keys"
```

Add the GitHub secrets `RAILS_MASTER_KEY` and `DEPLOY_SSH_KEY` (see the top-level README).

### 2. Test hostname

Point a new subdomain at the new droplet. It doesn't touch the live site.

```bash
doctl compute domain records create daniel-hillman.com \
  --record-type A --record-name new --record-data 152.42.155.192 --record-ttl 300
```

### 3. Restore the database into the app volume

Take a fresh copy from the legacy droplet, then copy it into the Docker volume. The app
runs as uid 1000.

```bash
scp digitalocean:dansite/db/production.sqlite3 ~/dansite-backups/cutover.sqlite3
scp ~/dansite-backups/cutover.sqlite3 deploy@152.42.155.192:/tmp/production.sqlite3
ssh deploy@152.42.155.192 '
  docker volume create dansite_storage &&
  docker run --rm -v dansite_storage:/data -v /tmp/production.sqlite3:/src.sqlite3:ro \
    alpine sh -c "cp /src.sqlite3 /data/production.sqlite3 && chown 1000:1000 /data/production.sqlite3" &&
  rm /tmp/production.sqlite3'
```

### 4. First deploy

```bash
bin/kamal setup     # or run the Deploy workflow in GitHub Actions
```

Check https://new.daniel-hillman.com: every page, project images, posts, and admin login.

### 5. Add the real hostnames

In `config/deploy.yml`, set `proxy.hosts` to:

```yaml
  hosts:
    - daniel-hillman.com
    - www.daniel-hillman.com
    - new.daniel-hillman.com
```

Deploy again. kamal-proxy requests a Let's Encrypt certificate for each host on its first
HTTPS request, so it's fine that DNS still points at the legacy droplet.

### 6. Switch DNS

```bash
doctl compute domain records list daniel-hillman.com           # find the ID of the `@` A record
doctl compute domain records update daniel-hillman.com \
  --record-id <ID> --record-data 152.42.155.192
```

`www` is a CNAME to `@`, so it follows automatically. The TTL is 1800s, so allow up to 30
minutes. Then check `http://` → `https://` and `www` → bare domain.

**Rollback:** set the `@` record back to `104.236.92.134`.

### 7. Decommission (after a week or so)

- Remove `new.daniel-hillman.com` from DNS and from `proxy.hosts`.
- Destroy the legacy droplet: `doctl compute droplet delete 3658373`.
- Remove the `digitalocean` entry from `~/.ssh/config`.

## Legacy droplet

`hillmandj.com` (ID 3658373, `104.236.92.134`, Ubuntu 14.04, nginx + Passenger) still
serves the live site until cutover. A backup of its database was taken on 2026-11-04
and kept outside the repo.
