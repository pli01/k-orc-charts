#!/usr/bin/env bash
set -euo pipefail

CHART_NAME="k-orc"
CHART_VERSION="${1:-latest}"
INSTALL_URL="https://github.com/k-orc/openstack-resource-controller/releases/download/${CHART_VERSION}/install.yaml"
case "$CHART_VERSION" in
  latest) INSTALL_URL="https://github.com/k-orc/openstack-resource-controller/releases/${CHART_VERSION}/download/install.yaml" ;;
esac

mkdir -p charts
rm -rf charts/"$CHART_NAME" || true

curl -sSL "$INSTALL_URL" -o patches/install.yaml
kubectl kustomize patches |helmify -preserve-ns charts/$CHART_NAME
rm -rf patches/install.yaml

(
  cd charts
  if  [ "$CHART_VERSION" != "latest" ]; then
    HELM_VERSION=${CHART_VERSION#v}
    sed -i .bak -e "s/^version:.*/version: $CHART_VERSION/g" $CHART_NAME/Chart.yaml
    sed -i .bak -e "s/^appVersion:.*/appVersion: \"$CHART_VERSION\"/g" $CHART_NAME/Chart.yaml
    rm $CHART_NAME/Chart.yaml.bak
  fi
)
echo "Helm chart in charts/$CHART_NAME"
