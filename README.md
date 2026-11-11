# helm-charts

Helm charts for [Arcanexus](https://arcanexus.com)' homelab Kubernetes (k3s) cluster.

Each top-level directory is a standalone chart with its own [SemVer](https://semver.org) version (`version` in its `Chart.yaml`). Every version is published as an OCI artifact to GitHub Container Registry and deployed by [ArgoCD](https://argo-cd.readthedocs.io/) from there, pinned to a version (no more `targetRevision: HEAD`).

```
oci://ghcr.io/arcanexus/charts/<chart-name>:<version>
```

## Usage

ArgoCD `Application`:

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
    repoURL: ghcr.io/arcanexus/charts   # no oci:// prefix, no repository Secret needed (public)
    chart: <chart-name>
    targetRevision: <version>
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
```

Plain Helm:

```bash
helm show values oci://ghcr.io/arcanexus/charts/<chart-name> --version <version>
helm template <release-name> oci://ghcr.io/arcanexus/charts/<chart-name> --version <version>
helm install <release-name> oci://ghcr.io/arcanexus/charts/<chart-name> --version <version> -n <namespace> --create-namespace
```

From a local checkout (to test a change before releasing it):

```bash
helm dependency update <chart-directory>   # only for charts with dependencies
helm template <release-name> <chart-directory>
```

## Releasing a chart

1. Change the chart and **bump `version`** in its `Chart.yaml` in the same pull request.
   The chart version **follows the main application it deploys**:
   - `version` = the application version without a leading `v` (image `portainer/portainer-ee:3.0.1`
     -> `3.0.1`, `ekofr/pihole-exporter:v1.3.1` -> `1.3.1`, `sharevb/it-tools:2026.10.25` -> `2026.10.25`);
     `appVersion` = the exact image tag. The image tag is pinned in `values.yaml`, not overridden
     in the Argo CD Application.
   - A chart-only change for the same application version adds a build suffix: `3.0.1+1`, `3.0.1+2`…
     (stored as OCI tag `3.0.1_1`; Argo CD `targetRevision: 3.0.1+1`).
   - Charts without one main application (cluster-base, http-redirects, monitoring, php, tools,
     test-chart, iperf3, speedtest-tracker) keep their own SemVer: patch for a fix or an image bump,
     minor for a new value, major when values change meaning.
2. The **Charts check** workflow fails the pull request if a changed chart keeps its version,
   if that version is already published, or if `helm lint` fails.
3. After the merge, the **Charts release** workflow packages every chart whose version is not
   in the registry yet, pushes it to `oci://ghcr.io/arcanexus/charts` and tags the commit
   `<chart-name>-<version>`. A published version is never overwritten.
4. Bump `targetRevision` of the Application in
   [gitops-argocd](https://github.com/Arcanexus/gitops-argocd) to roll it out.

The chart name is `name` in `Chart.yaml`, which is the directory name except for
`tailscale` (chart `tailscale-router`).

## Charts

Most charts are self-contained application charts (a Deployment/StatefulSet, Service, Ingress, etc.). A few are **wrapper charts**: they declare an upstream chart as a Helm dependency and layer homelab-specific config on top — most commonly static NFS-backed persistence instead of dynamic provisioning.

| Chart | Description | Wraps |
| --- | --- | --- |
| [authentik](authentik) | authentik add-ons (blueprints, blueprints watcher, reload job). Deployed next to the official chart as a second source of the Argo CD Application, which sets the authentik version | [goauthentik/authentik](https://charts.goauthentik.io) (separate source) |
| [bentopdf](bentopdf) | Deploys the bentopdf application | |
| [ctbrec](ctbrec) | CTBRec | |
| [erugo](erugo) | Erugo | |
| [freshrss](freshrss) | FreshRSS | |
| [gitea](gitea) | Wrapper chart for Gitea with static NFS-backed persistence | [gitea/gitea](https://dl.gitea.com/charts/) |
| [cluster-base](cluster-base) | Cluster-wide base objects: ClusterSecretStores (SSM, Bitwarden), ClusterIssuers (Let's Encrypt Route53, Bitwarden TLS chain), nfs StorageClass | |
| [homepage](homepage) | Homepage dashboard | |
| [http-redirects](http-redirects) | HTTP redirects using Traefik and cert-manager | |
| [immich](immich) | Immich, including the Immich Kiosk companion app | |
| [influxdb](influxdb) | Wrapper chart for InfluxDB with static NFS-backed persistence | |
| [iperf3](iperf3) | iPerf3 | |
| [it-tools](it-tools) | IT-Tools | |
| [krr](krr) | Robusta KRR resource recommendations, run on demand (suspended CronJob) | |
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
| [test-chart](test-chart) | Auth test chart — an nginx Hello World page per auth method (image with a shell), one Ingress each: Authentik, tinyauth, oauth2-proxy | |
| [tinyauth](tinyauth) | TinyAuth | |
| [tools](tools) | Deploys multiple small tools together (bentopdf, it-tools) | |
| [transmute](transmute) | Transmute | |
| [uptime-kuma](uptime-kuma) | uptime-kuma | |
| [wireguard](wireguard) | WireGuard VPN server | |

## Conventions

- Each chart's own metadata (name, version, description) lives in its `Chart.yaml`; check there and in `values.yaml` for the authoritative, up-to-date details and configurable values.
- Wrapper charts vendor an upstream chart via `dependencies:` in `Chart.yaml`. Run `helm dependency update <chart>` before templating/installing them locally — `charts/` and `Chart.lock` are gitignored and regenerated on demand.
- `test-chart` is a throwaway chart for exercising the pipeline/ArgoCD setup and the auth middlewares (Authentik, tinyauth, oauth2-proxy); it has no real application behind it.

## License

GPL-3.0 — see [LICENSE](LICENSE).
