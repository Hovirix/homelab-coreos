# Agent Instructions for CoreOS Homelab

You are a DevSecOps expert engineer working with a declarative Podman Quadlet infrastructure.

## Repository Structure

This repository contains declarative Quadlet container definitions for a self-hosted homelab. Each folder represents a service which may contain:
- Multiple `.container` files (container definitions)
- Multiple `.volume` files (volume definitions)
- Configuration files (e.g., `Caddyfile`, init scripts)

## Quadlet Workflow

### 1. Container Definition

Create a `.container` file with the following structure:
```ini
[Unit]
Description=Service name quadlet
Requires=dependency.container  # If depends on other containers
After=dependency.container

[Container]
Image=registry/image:tag
AutoUpdate=registry

Network=apps.network           # Always include
Network=db.network            # If uses PostgreSQL
NetworkAlias=service-name

Environment=KEY=value
Secret=SECRET_NAME,type=env,target=ENV_VAR_NAME

Volume=volume-name.volume:/path/in/container:Z
Volume=./file:/path/in/container:ro,Z  # For config files

[Service]
Restart=always
TimeoutStartSec=900

[Install]
WantedBy=default.target
```

**Key Points:**
- Use `AutoUpdate=registry` for automatic image updates
- Always add `:Z` for SELinux labeling on volumes
- Use `:ro,Z` for read-only config file mounts
- Reference volumes as `volume-name.volume`
- Use relative paths `./file` for local files

### 2. Volume Definition

Create a `.volume` file for each named volume:
```ini
[Volume]
```

### 3. Network Configuration

Three networks are available:
- **apps.network** - Application network (bridged, required for all apps)
- **db.network** - Database network (internal, for PostgreSQL access)
- **proxy.network** - Proxy network (for Caddy reverse proxy)

Containers should use:
- `apps.network` - Always required
- `db.network` - If connecting to PostgreSQL

### 4. Secrets Management

**Naming Convention:** Use `SERVICE_POSTGRESQL__PASSWORD` format for database passwords.

**For new secrets:**
1. Add secret creation to `install.sh`:
```bash
# Service Name
openssl rand -hex 16 | podman secret create --ignore SERVICE_POSTGRESQL__PASSWORD -
```

2. Reference in container:
```ini
Secret=SECRET_NAME,type=env,target=TARGET_ENV_VAR
```

3. If using PostgreSQL, add to `postgres/postgres.container`:
```ini
Secret=SERVICE_POSTGRESQL__PASSWORD,type=env,target=SERVICE_POSTGRESQL__PASSWORD
```

### 5. PostgreSQL Integration

**For services using PostgreSQL:**

1. Add secret to `postgres/postgres.container`:
```ini
Secret=SERVICE_POSTGRESQL__PASSWORD,type=env,target=SERVICE_POSTGRESQL__PASSWORD
```

2. Add database initialization to `postgres/init/01-init-databases.sh`:
```bash
CREATE ROLE servicename LOGIN PASSWORD '${SERVICE_POSTGRESQL__PASSWORD}';
CREATE DATABASE servicename OWNER servicename;
REVOKE ALL ON DATABASE servicename FROM PUBLIC;
```

3. Configure service container:
```ini
[Unit]
Requires=postgres.container
After=postgres.container

[Container]
Network=db.network
Network=apps.network

Environment=DB_HOST=postgres
Environment=DB_PORT=5432
Environment=DB_NAME=servicename
Environment=DB_USER=servicename
Secret=SERVICE_POSTGRESQL__PASSWORD,type=env,target=DB_PASSWORD
```

### 6. Reverse Proxy (Caddy)

Add service to `caddy/Caddyfile`:
```
service.nemnix.site {
	encode zstd gzip
	import security_headers
	reverse_proxy service-name:port
}
```

For Authentik-protected services:
```
service.nemnix.site {
	encode zstd gzip
	import security_headers
	route {
		import authentik
		reverse_proxy service-name:port
	}
}
```

### 7. Installation Script

Update `install.sh` to include the new service in the copy loop:
```bash
for service in authentik caddy immich linkwarden n8n paperless-ngx postgres traefik valkey vaultwarden newservice; do
```

## Checklist for Adding New Services

When adding a new service, verify:

- [ ] Container file created with proper naming (`service.container`)
- [ ] Volume files created for each volume (`volume-name.volume`)
- [ ] Networks configured correctly (`apps.network` required, `db.network` if needed)
- [ ] Dependencies set (`Requires=`, `After=`)
- [ ] Secrets added to `install.sh`
- [ ] If using PostgreSQL:
  - [ ] Secret added to `postgres/postgres.container`
  - [ ] Database initialization added to `postgres/init/01-init-databases.sh`
  - [ ] Service container has correct database configuration
- [ ] Service added to `caddy/Caddyfile`
- [ ] Service added to `install.sh` copy loop
- [ ] SELinux labels applied (`:Z` or `:ro,Z`)
- [ ] `AutoUpdate=registry` enabled
- [ ] Restart policy set (`Restart=always`)

## Output Format

When completing tasks, output concisely:

- Task 1: Created service.container
- Task 2: Created volume-name.volume  
- Task 3: Added secrets to install.sh
- Task 4: Configured PostgreSQL integration
- Task 5: Added service to Caddyfile  
