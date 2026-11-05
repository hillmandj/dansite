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

## Restoring the database

The app runs as uid 1000 and must own the volume directory as well as the file, because
SQLite writes journal files next to the database.

```bash
scp backup.sqlite3 deploy@152.42.155.192:/tmp/production.sqlite3
ssh deploy@152.42.155.192 '
  docker volume create dansite_storage &&
  docker run --rm -v dansite_storage:/data -v /tmp/production.sqlite3:/src.sqlite3:ro \
    alpine sh -c "cp /src.sqlite3 /data/production.sqlite3 && chown -R 1000:1000 /data" &&
  rm /tmp/production.sqlite3'
bin/kamal app boot   # or redeploy
```

## History

The site moved here on 2026-11-04 from a 2014 droplet (Ubuntu 14.04, nginx + Passenger,
Rails 4.0). It was tested at a temporary `new.daniel-hillman.com` hostname, then the `@`
A record was switched to the reserved IP. The old droplet was destroyed on 2026-11-05 after
its logs showed only bot traffic. Its final database backup is kept outside the repo.

When issuing certificates for a new hostname, wait until all DigitalOcean nameservers
(`dig @ns1/ns2/ns3.digitalocean.com`) return the new IP before the first HTTPS request:
Let's Encrypt validates from several locations and allows only 5 failures per hostname per hour.
