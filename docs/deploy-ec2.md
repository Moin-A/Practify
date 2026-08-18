# Deploying Practify to AWS EC2

Single EC2 instance running Docker Compose: Caddy (TLS) -> Puma, plus a Solid Queue
worker, Postgres, and Redis. No CI pipeline - deploys are `bin/deploy-ec2` over SSH.

## 1. Provision the instance

AWS console -> EC2 -> Launch instance:

| Setting | Value |
|---|---|
| AMI | Ubuntu Server 24.04 LTS (64-bit x86) |
| Type | t3.small |
| Key pair | create one, download the `.pem`, `chmod 400` it |
| Storage | 30 GiB gp3 |

Security group inbound rules:

| Port | Source | Why |
|---|---|---|
| 22 | your IP only | SSH |
| 80 | 0.0.0.0/0 | HTTP + Let's Encrypt challenge |
| 443 | 0.0.0.0/0 | HTTPS |

Then allocate an **Elastic IP** and associate it with the instance, so the address
survives a stop/start.

## 2. DNS

At your registrar, point both records at the Elastic IP:

```
practify.co.in       A    <elastic-ip>
www.practify.co.in   A    <elastic-ip>
```

If the records sit behind Cloudflare, set them to **DNS only** (grey cloud) until
Caddy has issued certificates, otherwise the ACME challenge fails.

## 3. Prepare the box

```bash
ssh -i practify.pem ubuntu@<elastic-ip>

# 2GB RAM cannot precompile assets without swap.
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y ca-certificates curl git

# Docker Engine + Compose plugin
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker ubuntu
newgrp docker   # or log out and back in
docker compose version
```

## 4. Clone and configure

```bash
git clone https://github.com/Moin-A/Practify.git ~/practify
cd ~/practify
cp .env.production.example .env.production
nano .env.production
```

Fill in every blank. `RAILS_MASTER_KEY` is the contents of `config/master.key` on
your laptop (`cat config/master.key`) - the app will not boot without it.
`POSTGRES_PASSWORD` and the password inside `DATABASE_URL` must match.

`.env.production` is gitignored and must never be committed.

## 5. First boot

```bash
./bin/deploy-ec2
```

The build takes 8-15 minutes on a t3.small. Then seed the roles and create your
first admin - a fresh database has none:

```bash
docker compose -f docker-compose.production.yml exec web ./bin/rails db:seed

docker compose -f docker-compose.production.yml exec web ./bin/rails runner '
  u = User.create!(email_address: "you@example.com",
                   password: "CHANGE_THIS",
                   password_confirmation: "CHANGE_THIS")
  u.roles = [Role.find_by!(name: "SuperAdmin")]
  u.save!
  puts "created #{u.email_address} as SuperAdmin"
'
```

New users default to the `Client` role (`User#set_default_role`), which is why the
role is reassigned explicitly.

## 6. Verify

```bash
curl -sI https://practify.co.in/up          # expect 200
docker compose -f docker-compose.production.yml ps        # all services up/healthy
docker compose -f docker-compose.production.yml logs -f worker   # Solid Queue polling
```

Then in a browser: log in as the SuperAdmin, upload a profile avatar, run
`docker compose -f docker-compose.production.yml restart web`, and confirm the
image still loads. That proves the `app_storage` volume is holding uploads.

## Redeploying

```bash
cd ~/practify && ./bin/deploy-ec2
```

## Operations

```bash
# Rails console
docker compose -f docker-compose.production.yml exec web ./bin/rails console

# Logs
docker compose -f docker-compose.production.yml logs -f web

# Database backup (do this on a schedule)
docker compose -f docker-compose.production.yml exec -T db \
  pg_dump -U practify practify_production | gzip > ~/backup-$(date +%F).sql.gz
```

## Troubleshooting

**Build killed / OOM** - confirm swap is on with `free -h`. Nothing else should be
building at the same time.

**Caddy cannot get a certificate** - DNS must resolve to the Elastic IP before Caddy
starts, port 80 must be open to the world, and Cloudflare proxying must be off.
Check with `docker compose -f docker-compose.production.yml logs caddy`.

**Blocked host** - add the hostname to `APP_HOSTS` in `.env.production` and restart
`web`.

**Mail does not send** - see the note in `config/environments/production.rb`: the
mailer is set to `:smtp` but `smtp_settings` is populated with SES API keys rather
than SMTP address/port/credentials. This needs fixing before any mail works.
