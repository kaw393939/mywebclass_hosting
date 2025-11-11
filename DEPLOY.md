# Server Deployment Instructions

## Quick Deploy (For Production Server)

### 1. Clone Repository
```bash
git clone git@github.com:kaw393939/mywebclass_hosting.git mywebclass.org
cd mywebclass.org
```

### 2. Configure Environment
```bash
# Copy environment template
cp .env.example .env

# Edit with your credentials
nano .env
```

**Required values in .env:**
- `CF_DNS_API_TOKEN` - Cloudflare API token (needs DNS edit permissions)
- `CF_ZONE_API_TOKEN` - Cloudflare Zone API token
- `TRAEFIK_DASHBOARD_CREDENTIALS` - Generate with command below

**Generate dashboard password:**
```bash
docker run --rm httpd:2.4-alpine htpasswd -nbB admin "YourPassword" | sed -e s/\\$/\\$\\$/g
```

Copy the output and paste it as the value for `TRAEFIK_DASHBOARD_CREDENTIALS` in `.env`

### 3. Update Email for Let's Encrypt
```bash
nano traefik/traefik.yml
```

Change the email address in the `certificatesResolvers` section:
```yaml
certificatesResolvers:
  cloudflare:
    acme:
      email: your-email@mywebclass.org  # UPDATE THIS
```

### 4. Set Permissions
```bash
chmod 600 traefik/acme.json
```

### 5. Start Services
```bash
docker-compose up -d
```

### 6. Verify Deployment
```bash
# Check all containers are running
docker-compose ps

# Check logs
docker-compose logs -f

# Test SSL certificate generation
docker-compose logs traefik | grep -i acme
```

## DNS Configuration

Before starting, ensure these DNS records exist in Cloudflare:

```
Type    Name                        Value
A       mywebclass.org              YOUR_SERVER_IP
A       www.mywebclass.org          YOUR_SERVER_IP
A       traefik.mywebclass.org      YOUR_SERVER_IP
```

Or use wildcard:
```
Type    Name                Value
A       mywebclass.org      YOUR_SERVER_IP
A       *.mywebclass.org    YOUR_SERVER_IP
```

## Getting Cloudflare API Tokens

1. Log in to Cloudflare Dashboard
2. Go to: My Profile → API Tokens
3. Create Token with these permissions:
   - Zone - DNS - Edit
   - Zone - Zone - Read
4. Copy the token to your `.env` file

## Updating the Site

When you make changes locally and push to GitHub:

```bash
# On the server
cd mywebclass.org
git pull origin main
docker-compose restart httpd
```

Watchtower will automatically update container images every hour.

## Troubleshooting

### View logs
```bash
docker-compose logs -f [traefik|httpd|watchtower]
```

### Restart services
```bash
docker-compose restart
```

### Reset SSL certificates
```bash
docker-compose down
rm traefik/acme.json
touch traefik/acme.json
chmod 600 traefik/acme.json
docker-compose up -d
```

### Check service status
```bash
docker-compose ps
docker stats
```

## Accessing Services

- Main site: <https://mywebclass.org>
- Traefik dashboard: <https://traefik.mywebclass.org> (password protected)

## Security Checklist

- [ ] `.env` file created with real credentials (not committed to git)
- [ ] `acme.json` has 600 permissions
- [ ] Strong password set for Traefik dashboard
- [ ] Cloudflare API tokens have minimal required permissions
- [ ] Firewall allows ports 80 and 443
- [ ] DNS records pointing to correct server IP

## Monitoring

Watchtower will automatically:
- Check for updates every hour
- Pull new images when available
- Restart containers with new images
- Clean up old images

View Watchtower activity:
```bash
docker-compose logs watchtower
```
