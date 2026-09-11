# helm-charts

Helm charts for [Arcanexus](https://arcanexus.com)' homelab Kubernetes (k3s) cluster. Each top-level directory is a standalone chart, deployed by [ArgoCD](https://argo-cd.readthedocs.io/) directly from this git repository (no chart repository / `index.yaml` — Argo `Application` resources point at a path here with `targetRevision: HEAD`).

## Usage

These charts aren't published to a Helm repo. Reference them straight from git, either with an ArgoCD `Application`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: <app-name>
  namespace: argocd
spec:
  destination:
    name: in-cluster
    namespace: <app-name>
  project: default
  source:
    path: <chart-directory>
    repoURL: https://github.com/Arcanexus/helm-charts.git
    targetRevision: HEAD
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
```

or locally with plain Helm:

```bash
helm dependency update <chart-directory>   # only needed for charts with dependencies, see below
helm template <chart-directory>
helm install <release-name> <chart-directory> -n <namespace> --create-namespace
```

## Charts

Most charts are self-contained application charts (a Deployment/StatefulSet, Service, Ingress, etc.). A few are **wrapper charts**: they declare an upstream chart as a Helm dependency and layer homelab-specific config on top — most commonly static NFS-backed persistence instead of dynamic provisioning.

| Chart | Description | Wraps |
| --- | --- | --- |
| [authentik](authentik) | Wrapper chart for authentik with static NFS-backed PostgreSQL persistence | [goauthentik/authentik](https://charts.goauthentik.io) |
| [bentopdf](bentopdf) | Deploys the bentopdf application | |
| [ctbrec](ctbrec) | CTBRec | |
| [erugo](erugo) | Erugo | |
| [freshrss](freshrss) | FreshRSS | |
| [gitea](gitea) | Wrapper chart for Gitea with static NFS-backed persistence | [gitea/gitea](https://dl.gitea.com/charts/) |
| [homepage](homepage) | Homepage dashboard | |
| [http-redirects](http-redirects) | HTTP redirects using Traefik and cert-manager | |
| [immich](immich) | Immich, including the Immich Kiosk companion app | |
| [influxdb](influxdb) | Wrapper chart for InfluxDB with static NFS-backed persistence | |
| [iperf3](iperf3) | iPerf3 | |
| [it-tools](it-tools) | IT-Tools | |
| [komga](komga) | Komga | |
| [linkwarden](linkwarden) | Linkwarden | |
| [litellm](litellm) | LiteLLM | |
| [loki](loki) | Loki | |
| [loki-exporter](loki-exporter) | loki-exporter | |
| [mediawiki](mediawiki) | MediaWiki | |
| [monitoring](monitoring) | Monitoring stack | |
| [monitoring-healthckecksio](monitoring-healthckecksio) | healthchecks.io monitoring | |
| [n8n](n8n) | n8n, single or scalable mode | |
| [omnitool](omnitool) | Omnitool | |
| [php](php) | Generic PHP app | |
| [pihole-exporter](pihole-exporter) | pihole-exporter | |
| [portainer](portainer) | Portainer | |
| [searxng](searxng) | SearXNG metasearch engine | |
| [shlink](shlink) | Shlink URL shortener | |
| [skooner](skooner) | Skooner Kubernetes dashboard | |
| [snmp-exporter](snmp-exporter) | snmp-exporter | |
| [speedtest-exporter](speedtest-exporter) | speedtest-exporter | |
| [speedtest-tracker](speedtest-tracker) | speedtest-tracker | |
| [stash](stash) | Stash | |
| [suwayomi](suwayomi) | Suwayomi | |
| [tailscale](tailscale) | Tailscale subnet router / exit node for k3s | |
| [technitiumdns](technitiumdns) | Technitium DNS Server | |
| [tesladash](tesladash) | Tesla dashboard | |
| [teslamate](teslamate) | TeslaMate | |
| [test-chart](test-chart) | Generic test chart — deploys an `ubuntu:latest` pod with configurable service and ingress | |
| [tinyauth](tinyauth) | TinyAuth | |
| [tools](tools) | Deploys multiple small tools together (bentopdf, it-tools) | |
| [transmute](transmute) | Transmute | |
| [uptime-kuma](uptime-kuma) | uptime-kuma | |
| [wireguard](wireguard) | WireGuard VPN server | |

## Conventions

- Each chart's own metadata (name, version, description) lives in its `Chart.yaml`; check there and in `values.yaml` for the authoritative, up-to-date details and configurable values.
- Wrapper charts vendor an upstream chart via `dependencies:` in `Chart.yaml`. Run `helm dependency update <chart>` before templating/installing them locally — `charts/` and `Chart.lock` are gitignored and regenerated on demand.
- `test-chart` is a throwaway chart for exercising the pipeline/ArgoCD setup; it has no real application behind it.

## License

GPL-3.0 — see [LICENSE](LICENSE).
