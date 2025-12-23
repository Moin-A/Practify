# Kamal Traefik Troubleshooting Guide

This guide documents how to diagnose connection issues between Traefik and your Rails web container.

## Quick Diagnosis Flow

```
Browser → Traefik → Web Container → Rails App
   ↓         ↓           ↓            ↓
  DNS    Ports/SSL    Network     Health Check
```

---

## How to Find the Issue: The Diagnostic Process

When your site isn't loading, follow this investigation pattern to pinpoint the problem:

### Step 1: Check the Basics ✅
```bash
docker ps
```
**Goal:** Confirm containers are running
- Is Traefik running?
- Is web container running and healthy?
- Does Traefik show both ports 80 and 443?

### Step 2: Check if Rails is Working ✅
```bash
docker exec <web-container> curl -f http://localhost:3000/up && echo "SUCCESS" || echo "FAILED"
```
**Goal:** Verify Rails app is responding
- If FAILED → Problem is Rails (check logs, database, env vars)
- If SUCCESS → Problem is with routing/Traefik

### Step 3: Verify Container Labels ✅
```bash
docker inspect <web-container> --format='{{range $key, $value := .Config.Labels}}{{$key}}={{$value}}{{println}}{{end}}' | grep traefik
```
**Goal:** Confirm Traefik knows about your container
- Should show `traefik.enable=true`
- Should show routing rules for your domain
- If missing → Problem is Kamal deployment config

### Step 4: Test Routing from Server ⚠️
```bash
curl -v -H "Host: practify.co.in" http://localhost
```
**Goal:** Test if Traefik can route to backend

**Response codes tell the story:**
- `200 OK` → Everything works! Problem is external (DNS, firewall)
- `502 Bad Gateway` → 🔍 **Traefik can't reach backend** (network or Traefik config issue)
- `404 Not Found` → Routing works but no matching route
- Connection timeout → Traefik not running or wrong port

### Step 5: Check Traefik Logs 🎯 **THE KEY STEP**
```bash
docker logs traefik --tail 50 | grep -E "(error|entrypoint|websecure|letsencrypt)"
```
**Goal:** Find Traefik configuration errors

**Critical errors to look for:**
```
❌ entryPoint "websecure" doesn't exist
❌ entryPoint "web" doesn't exist
❌ resolver "letsencrypt" doesn't exist
```

**If you see these:** Traefik is running but missing configuration!

### The Breakthrough Pattern:

```
Container labels: "Use websecure entrypoint"
       ↓
Traefik: "What is websecure? I don't have that!"
       ↓
ERROR: Traefik wasn't started with proper entrypoints
```

**The Fix:** Boot Traefik with complete configuration:
```bash
docker run --name traefik ... \
  --entrypoints.web.address=:80 \
  --entrypoints.websecure.address=:443 \
  --certificatesresolvers.letsencrypt.acme.email=admin@example.com
```

### Why This Diagnostic Order Works:

1. **502 Bad Gateway** tells you: Traefik received request but can't forward it
2. **Rails responding** tells you: Backend is fine
3. **Labels correct** tells you: Container config is fine
4. **Therefore:** Problem must be Traefik itself
5. **Logs confirm:** Missing entrypoint configuration

**Key Insight:** Follow the request path and eliminate possibilities until you find where it breaks!

---

## 1. Check Container Status

### View all running containers
```bash
docker ps
```

**What to verify:**
- ✅ Traefik container is running
- ✅ Web container is running and healthy
- ✅ Traefik shows both ports: `0.0.0.0:80->80/tcp` and `0.0.0.0:443->443/tcp`

### Check specific container logs
```bash
# Web container logs
docker logs <web-container-name> --tail 50

# Traefik logs
docker logs traefik --tail 100

# Follow logs in real-time
docker logs -f traefik
```

---

## 2. Verify Rails is Running

### Check if Rails/Puma is listening on port 3000
```bash
docker logs <web-container-name> --tail 20
```

**Expected output:**
```
* Listening on http://0.0.0.0:3000
```

### Test Rails health endpoint directly
```bash
# Test from inside the container
docker exec <web-container-name> curl -f --max-time 5 http://localhost:3000/up && echo "SUCCESS" || echo "FAILED"

# Check what ports are listening
docker exec <web-container-name> netstat -tlnp | grep LISTEN
```

---

## 3. Verify Traefik Labels on Web Container

### Check if container has correct Traefik labels
```bash
docker inspect <web-container-name> --format='{{range $key, $value := .Config.Labels}}{{$key}}={{$value}}{{println}}{{end}}' | grep traefik
```

**Required labels:**
```
traefik.enable=true
traefik.http.routers.<service>-web.rule=Host(`your-domain.com`)
traefik.http.routers.<service>-web.entrypoints=websecure
traefik.http.routers.<service>-web.tls.certresolver=letsencrypt
traefik.http.services.<service>-web.loadbalancer.server.port=3000
```

---

## 4. Check Traefik Configuration

### Verify Traefik has proper entrypoints
```bash
docker logs traefik --tail 50 | grep -E "(entrypoint|websecure|letsencrypt)"
```

**Look for these errors (BAD):**
```
❌ entryPoint "websecure" doesn't exist
❌ entryPoint "web" doesn't exist
❌ resolver "letsencrypt" doesn't exist
```

**Good output should show:**
```
✅ Adding route for your-domain.com with TLS options
✅ Creating middleware
✅ Creating load-balancer
```

### Check Traefik routing configuration
```bash
docker logs traefik --tail 100 | grep -i "practify"
```

---

## 5. Test Network Connectivity

### Check if containers are on the same network
```bash
# Check web container's networks
docker inspect <web-container-name> --format='{{range $key, $value := .NetworkSettings.Networks}}{{$key}}{{println}}{{end}}'

# Check Traefik's networks
docker inspect traefik --format='{{range $key, $value := .NetworkSettings.Networks}}{{$key}}{{println}}{{end}}'
```

**Both should be on the same network (usually `bridge`)**

### Test if Traefik can reach web container
```bash
docker exec traefik ping -c 2 <web-container-name>
```

---

## 6. Test HTTP/HTTPS Routing

### Test from the server itself
```bash
# Test HTTP routing (should work or redirect to HTTPS)
curl -v -H "Host: your-domain.com" http://localhost

# Test HTTPS (ignore certificate warnings for testing)
curl -v -k https://localhost -H "Host: your-domain.com"
```

**Response codes:**
- `200 OK` = Working! ✅
- `502 Bad Gateway` = Traefik can't reach web container (network issue)
- `404 Not Found` = Routing works but no route matches
- Connection timeout = Traefik not running or ports blocked

### Test from your local machine
```bash
# Test HTTP
curl -v http://your-domain.com

# Test HTTPS
curl -v https://your-domain.com
```

---

## 7. Verify DNS Configuration

### Check DNS resolution
```bash
dig your-domain.com +short
nslookup your-domain.com
```

**Should return your server's IP address**

### Compare with server IP
```bash
# On server
curl ifconfig.me
```

---

## 8. Check Firewall/Security Groups

### Verify ports are open
```bash
# Check if ports 80 and 443 are listening
netstat -tlnp | grep -E ":(80|443)"

# Check firewall rules (Ubuntu/Debian)
sudo ufw status

# List iptables rules
sudo iptables -L -n
```

**Required ports:**
- Port 80 (HTTP) - Open to 0.0.0.0/0
- Port 443 (HTTPS) - Open to 0.0.0.0/0
- Port 22 (SSH) - Open to your IP

---

## 9. Check SSL Certificate Status

### View Traefik certificate storage
```bash
# Check if certificate file exists
ls -lah /opt/letsencrypt/

# View certificate details
sudo cat /opt/letsencrypt/acme.json | grep -A 10 "your-domain.com"
```

### Check Traefik SSL logs
```bash
docker logs traefik 2>&1 | grep -i "certificate\|acme\|letsencrypt"
```

---

## Common Issues and Solutions

### Issue: 502 Bad Gateway

**Cause:** Traefik can't reach the web container

**Check:**
1. Are containers on the same network?
2. Is Rails responding on port 3000?
3. Are Traefik labels correct?

**Fix:**
```bash
# Restart web container
kamal app restart

# Check web container health
docker exec <web-container-name> curl localhost:3000/up
```

### Issue: Connection Timeout

**Cause:** Traefik not running or ports blocked

**Check:**
1. Is Traefik running?
2. Is port 443 open in security group?
3. Is firewall blocking ports?

**Fix:**
```bash
# Verify Traefik ports
docker ps | grep traefik

# Reboot Traefik
docker stop traefik && docker rm traefik
# Then redeploy
```

### Issue: "entryPoint doesn't exist" errors

**Cause:** Traefik started without proper configuration

**Check:**
```bash
docker logs traefik | grep -i "entrypoint.*doesn't exist"
```

**Fix:** Ensure Traefik is booted with entrypoints:
```bash
docker run --name traefik --detach --restart unless-stopped \
  --publish 80:80 --publish 443:443 \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume /opt/letsencrypt:/letsencrypt \
  traefik:v2.10 \
  --providers.docker=true \
  --entrypoints.web.address=:80 \
  --entrypoints.websecure.address=:443 \
  --certificatesresolvers.letsencrypt.acme.email=admin@example.com \
  --certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json \
  --certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web
```

### Issue: Rails not responding

**Cause:** Rails failed to start or crashed

**Check:**
```bash
# View Rails logs
docker logs <web-container-name> --tail 100

# Check if Puma is running
docker exec <web-container-name> ps aux | grep puma
```

**Common causes:**
- Missing RAILS_MASTER_KEY
- Database connection error
- Port already in use
- Failed migrations

---

## Quick Recovery Commands

### Restart everything
```bash
# Stop all
docker stop traefik
docker rm traefik
kamal app stop

# Start fresh
kamal traefik boot
kamal deploy
```

### Force remove stuck Traefik
```bash
# Nuclear option - removes any container using ports 80/443
docker ps -a --filter 'publish=80' --filter 'publish=443' -q | xargs -r docker rm -f
```

### Check everything at once
```bash
echo "=== Container Status ==="
docker ps

echo -e "\n=== Traefik Ports ==="
docker ps | grep traefik

echo -e "\n=== Rails Health ==="
docker exec $(docker ps -q -f name=web) curl -f http://localhost:3000/up && echo "✅ Rails OK" || echo "❌ Rails FAILED"

echo -e "\n=== Traefik Labels ==="
docker inspect $(docker ps -q -f name=web) --format='{{range $key, $value := .Config.Labels}}{{if eq $key "traefik.enable"}}{{$key}}={{$value}}{{println}}{{end}}{{end}}'

echo -e "\n=== Traefik Errors ==="
docker logs traefik --tail 20 | grep -i error
```

---

## Useful Kamal Commands

```bash
# View app status
kamal app details

# Restart app containers
kamal app restart

# View app logs
kamal app logs -f

# Restart Traefik
kamal traefik reboot

# View Traefik logs
kamal traefik logs

# SSH into web container
kamal app exec -i bash

# Check deployed version
kamal app version
```

---

## Monitoring in Production

### Set up log monitoring
```bash
# Watch Traefik logs
watch -n 2 'docker logs traefik --tail 10'

# Watch web container logs
kamal app logs -f
```

### Health check endpoints
```bash
# Application health
curl https://your-domain.com/up

# Traefik dashboard (if enabled)
curl http://localhost:8080/api/http/routers
```

---

## Getting Help

If you're still stuck after going through this guide:

1. Check Kamal documentation: https://kamal-deploy.org
2. Check Traefik documentation: https://doc.traefik.io/traefik/
3. Review CircleCI logs for deployment errors
4. Check server system logs: `journalctl -xe`

---

## Summary Checklist

Before asking for help, verify:

- [ ] Traefik container is running with ports 80 and 443
- [ ] Web container is running and healthy
- [ ] Rails is responding on localhost:3000
- [ ] Traefik has correct entrypoints (web, websecure)
- [ ] Web container has traefik.enable=true label
- [ ] DNS points to correct server IP
- [ ] Firewall allows ports 80 and 443
- [ ] No "entryPoint doesn't exist" errors in Traefik logs
- [ ] Containers are on the same Docker network

