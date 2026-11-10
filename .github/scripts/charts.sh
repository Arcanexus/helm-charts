#!/usr/bin/env bash
# Helpers for the chart workflows. Every top-level directory with a Chart.yaml
# is a chart, published as oci://ghcr.io/<owner>/charts/<name>:<version>.
#
#   charts.sh list                    all chart directories
#   charts.sh changed <base-ref>      chart directories changed since <base-ref>
#   charts.sh field <dir> <key>       a top-level field of <dir>/Chart.yaml
#   charts.sh published <name> <ver>  exit 0 if the version is in the registry,
#                                     1 if not, 2 on any other registry error
#
# Needs REGISTRY_USER and REGISTRY_TOKEN (GITHUB_TOKEN with packages: read) for
# "published", and OCI_REPO (ghcr.io/<owner>/charts, lower case).
set -euo pipefail

cmd=${1:-}; shift || true

list() {
  for f in */Chart.yaml; do dirname "$f"; done
}

field() {
  # Plain top-level "key: value" (Chart.yaml never nests these), quotes removed
  awk -v k="$2" '$1 == k":" { sub(/^[^:]*:[ \t]*/, ""); gsub(/["'\'']/, ""); sub(/[ \t]+#.*$/, ""); print; exit }' "$1/Chart.yaml"
}

case "$cmd" in
  list) list ;;
  changed)
    base=$1
    git diff --name-only "$base" HEAD -- | cut -d/ -f1 | sort -u | while read -r d; do
      [ -f "$d/Chart.yaml" ] && echo "$d"
    done
    ;;
  field) field "$1" "$2" ;;
  published)
    name=$1; version=$2
    repo="${OCI_REPO#ghcr.io/}/$name"
    token=$(curl -fsS -u "${REGISTRY_USER}:${REGISTRY_TOKEN}" \
      "https://ghcr.io/token?service=ghcr.io&scope=repository:${repo}:pull" | jq -r .token) || exit 2
    # OCI tags cannot hold "+", Helm writes "_" instead
    tag=${version//+/_}
    code=$(curl -sS -o /dev/null -w '%{http_code}' \
      -H "Authorization: Bearer $token" \
      -H "Accept: application/vnd.oci.image.manifest.v1+json" \
      "https://ghcr.io/v2/${repo}/manifests/${tag}")
    case "$code" in
      200) exit 0 ;;
      404) exit 1 ;;
      # A package that does not exist yet can answer "denied" instead of 404
      401|403) echo "registry answered HTTP $code for ${repo}:${tag}, taken as not published" >&2; exit 1 ;;
      *) echo "registry answered HTTP $code for ${repo}:${tag}" >&2; exit 2 ;;
    esac
    ;;
  *) echo "usage: $0 list|changed|field|published" >&2; exit 64 ;;
esac
