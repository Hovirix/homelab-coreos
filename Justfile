user := "core"
server := "192.168.1.226"

create-secrets:
    sops -d secrets.yaml | yq -r '.postgres.password' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore POSTGRES_PASSWORD -'
    sops -d secrets.yaml | yq -r '.postgres.n8n_password' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore N8N_PASSWORD -'
    sops -d secrets.yaml | yq -r '.postgres.immich_password' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore IMMICH_PASSWORD -'
    sops -d secrets.yaml | yq -r '.postgres.grafana_password' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore GRAFANA_PASSWORD -'
    sops -d secrets.yaml | yq -r '.postgres.paperless_password' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore PAPERLESS_PASSWORD -'
    sops -d secrets.yaml | yq -r '.postgres.authentik_password' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore AUTHENTIK_PASSWORD -'
    sops -d secrets.yaml | yq -r '.postgres.linkwarden_password' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore LINKWARDEN_PASSWORD -'

    sops -d secrets.yaml | yq -r '.app.nextauth_secret' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore NEXTAUTH_SECRET -'
    sops -d secrets.yaml | yq -r '.app.meili_master_key' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore MEILI_MASTER_KEY -'
    sops -d secrets.yaml | yq -r '.app.authentik_secret_key' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore AUTHENTIK_SECRET_KEY -'
    sops -d secrets.yaml | yq -r '.app.paperless_secret_key' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore PAPERLESS_SECRET_KEY -'
    sops -d secrets.yaml | yq -r '.app.linkwarden_database_url' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore LINKWARDEN_DATABASE_URL -'

    sops -d secrets.yaml | yq -r '.oauth.linkwarden.client_id' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore LINKWARDEN_OAUTH_CLIENT_ID -'
    sops -d secrets.yaml | yq -r '.oauth.linkwarden.client_secret' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore LINKWARDEN_OAUTH_CLIENT_SECRET -'
    sops -d secrets.yaml | yq -r '.oauth.immich.client_id' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore IMMICH_OAUTH_CLIENT_ID -'
    sops -d secrets.yaml | yq -r '.oauth.immich.client_secret' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore IMMICH_OAUTH_CLIENT_SECRET -'
    sops -d secrets.yaml | yq -r '.oauth.paperless.client_id' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore PAPERLESS_OAUTH_CLIENT_ID -'
    sops -d secrets.yaml | yq -r '.oauth.paperless.client_secret' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore PAPERLESS_OAUTH_CLIENT_SECRET -'

    sops -d secrets.yaml | yq -r '.api_token.authentik' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore AUTHENTIK_API_TOKEN -'
    sops -d secrets.yaml | yq -r '.api_token.cloudflare_dns_challenge' | tr -d '\n' | ssh {{user}}@{{server}} 'podman secret create --ignore CLOUDFLARE_DNS_CHALLENGE_TOKEN -'

copy-configs:
    scp -r ./quadlets/* {{user}}@{{server}}:~/.config/containers/systemd/

