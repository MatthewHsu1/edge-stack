# edge-stack

Docker Compose stack for exposing a self-hosted service through Tailscale Funnel.

This repository currently runs:

- `tailscale/tailscale` as the public edge and Funnel endpoint
- `n8n` behind the Tailscale container on the `/n8n/` path

## What This Stack Does

- Starts a Tailscale container with Funnel enabled through `containerboot`
- Renders a Funnel config from `funnel.json.template`
- Publishes HTTPS traffic on port `443`
- Proxies `https://<your-ts-domain>/n8n/` to the local `n8n` service

## Repo Files

- [`docker-compose.yml`](/root/Projects/App%20Server/docker-compose.yml): main service definition
- [`funnel.json.template`](/root/Projects/App%20Server/funnel.json.template): Tailscale Funnel template
- [`render-funnel-and-start.sh`](/root/Projects/App%20Server/render-funnel-and-start.sh): renders the Funnel config and starts `containerboot`
- [`.env`](/root/Projects/App%20Server/.env): local environment values used by Compose

## Prerequisites

- Docker and Docker Compose installed
- A Tailscale account
- A valid Tailscale auth key with the permissions you need
- Funnel enabled on the tailnet and domain you plan to use
- A pre-created Docker volume named `n8n_data`

Create the persistent `n8n` volume if it does not already exist:

```bash
docker volume create n8n_data
```

## Environment Variables

Create or update `.env` with:

```dotenv
TS_AUTHKEY=your_tailscale_auth_key
TS_HOSTNAME=your_node_name
TS_DOMAIN=your_tailnet_domain
```

Variable notes:

- `TS_AUTHKEY`: auth key used by the Tailscale container
- `TS_HOSTNAME`: hostname registered in Tailscale
- `TS_DOMAIN`: HTTPS host used in the Funnel config and `n8n` URLs

## Start The Stack

```bash
docker compose up -d
```

To inspect logs:

```bash
docker compose logs -f
```

To stop the stack:

```bash
docker compose down
```

## Expected Result

After the containers start successfully:

- Tailscale should join your tailnet
- the rendered config should publish HTTPS on your Tailscale domain
- `n8n` should be available at:

```text
https://<TS_DOMAIN>/n8n/
```

## How It Works

`render-funnel-and-start.sh` requires `TS_DOMAIN`, renders `/config/funnel.json` from `funnel.json.template`, and then hands off to Tailscale `containerboot`.

The `n8n` container shares the Tailscale container network namespace with:

```yaml
network_mode: "service:tailscale"
```

That lets Funnel proxy traffic directly to `http://127.0.0.1:5678`.
