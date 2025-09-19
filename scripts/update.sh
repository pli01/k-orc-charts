#!/usr/bin/env bash
set -euo pipefail

CHART_NAME="k-orc"
CHART_VERSION="${1:-latest}"
INSTALL_URL="https://github.com/k-orc/openstack-resource-controller/releases/download/${CHART_VERSION}/install.yaml"
case "$CHART_VERSION" in
  latest) INSTALL_URL="https://github.com/k-orc/openstack-resource-controller/releases/${CHART_VERSION}/download/install.yaml" ;;
esac

rm -rf "$CHART_NAME"
curl -sSL "$INSTALL_URL" | helmify "$CHART_NAME"

if  [ "$CHART_VERSION" != "latest" ]; then
HELM_VERSION=${CHART_VERSION#v}
sed -i -e "s/^version:.*/version: $HELM_VERSION/g" $CHART_NAME/Chart.yaml
sed -i -e "s/^appVersion:.*/appVersion: \"$CHART_VERSION\"/g" $CHART_NAME/Chart.yaml
fi
echo "Helm chart in ./$CHART_NAME"
