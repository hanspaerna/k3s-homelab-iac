#!/bin/sh

#
# This script helps following the Rendered Manifests Pattern.
# Instead of relying on 3rd-party Helm charts repositories, they will be needed only for fetching the newer versions of the charts.
# After each execution, a new manifest.readonly.yaml in a corresponding app folder under flux/base/ will be created.
#
#
# ! If one is needed, ensure that you have created "values-base.yaml" inside the application folder under flux/base/.
# ! The "values-base.yaml" should contain a minimal set of value that configures the result of rendering. 
# ! Use Flux+Kustomize for everything else in env-specific overlays.
# ! Please note that "manifest.readonly.yaml" should never be manually edited as it will be overwritten during the next script execution.
# ! The script ignores CRDs if they present in charts (mostly infrastructural ones). You have to get them separately and install as a part of infrastructure.
#

set -euo pipefail

usage() {
  cat <<EOF
Usage:
  $0 --chart NAME \\
     --repo URL \\
     --version VERSION \\
     --release NAME \\
     --namespace NAMESPACE
     --is-infrastructure BOOL

Required flags:
  --chart              Helm chart name (e.g. traefik)
  --repo               Helm chart repository URL
  --version            Chart version (pinned)
  --release            Helm release name
  --namespace          Kubernetes namespace
  --is-infrastructure  Should be installed either in "apps/base" or "infrastructure/base"

EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --chart)
      CHART_NAME="$2"
      shift 2
      ;;
    --repo)
      CHART_REPO="$2"
      shift 2
      ;;
    --version)
      CHART_VERSION="$2"
      shift 2
      ;;
    --release)
      RELEASE_NAME="$2"
      shift 2
      ;;
    --namespace)
      NAMESPACE="$2"
      shift 2
      ;;
    --is-infrastructure)
      IS_INFRASTRUCTURE="$2"
      shift 2
      ;;
    --*)
      echo "Unknown option: $1"
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

if [[ $? -ne 0 ]]; then
  usage
fi

: "${CHART_NAME:?Missing --chart}"
: "${CHART_REPO:?Missing --repo}"
: "${CHART_VERSION:?Missing --version}"
: "${RELEASE_NAME:?Missing --release}"
: "${NAMESPACE:?Missing --namespace}"
: "${IS_INFRASTRUCTURE:?Missing --is-infrastructure}"

INSTALLATION_TYPE="apps"

if [ "$IS_INFRASTRUCTURE" = true ] ; then
    INSTALLATION_TYPE="infrastructure"
fi

OUTPUT_FILE="./flux/${INSTALLATION_TYPE}/base/${RELEASE_NAME}/manifest.readonly.yaml"
VALUES_FILE="./flux/${INSTALLATION_TYPE}/base/${RELEASE_NAME}/values-base.yaml"
REPO_NAME="temp-repo-$(echo "${CHART_NAME}" | tr '/' '-')"

cleanup() {
  helm repo remove "${REPO_NAME}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

helm repo add "${REPO_NAME}" "${CHART_REPO}" >/dev/null
helm repo update >/dev/null

echo "Rendering ${CHART_NAME}@${CHART_VERSION} → ${OUTPUT_FILE}"

if [[ -f "${VALUES_FILE}" ]]; then
  helm template "${RELEASE_NAME}" "${REPO_NAME}/${CHART_NAME}" \
    --version "${CHART_VERSION}" \
    --namespace "${NAMESPACE}" \
    --skip-crds \
    --values "${VALUES_FILE}" \
    > "${OUTPUT_FILE}"
else
  helm template "${RELEASE_NAME}" "${REPO_NAME}/${CHART_NAME}" \
    --version "${CHART_VERSION}" \
    --namespace "${NAMESPACE}" \
    --skip-crds \
    > "${OUTPUT_FILE}"
fi

echo "[DONE] Manifest rendered (read-only, CRDs excluded)"

