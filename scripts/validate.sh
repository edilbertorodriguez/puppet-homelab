#!/usr/bin/env bash

set -euo pipefail

echo "[1/6] Validating Puppet manifests..."
puppet parser validate \
  environments/production/manifests/site.pp \
  modules/common/manifests/init.pp \
  modules/ssh_hardening/manifests/init.pp

echo "[2/6] Validating EPP templates..."
puppet epp validate \
  modules/ssh_hardening/templates/99-puppet-hardening.conf.epp

echo "[3/6] Validating YAML files..."
ruby -e "
require 'yaml'
YAML.load_file('environments/production/hiera.yaml')
YAML.load_file('environments/production/data/common.yaml')
YAML.load_file('environments/production/data/nodes/ubuntu-test01.yaml')
YAML.load_file('environments/production/data/nodes/ubuntu-test02.yaml')
"

echo "[4/6] Validating Hiera lookups..."
puppet lookup common::managed_file_mode \
  --environmentpath="$(pwd)/environments" \
  --environment=production \
  --modulepath="$(pwd)/modules" >/dev/null

puppet lookup ssh_hardening::permit_root_login \
  --environmentpath="$(pwd)/environments" \
  --environment=production \
  --modulepath="$(pwd)/modules" >/dev/null

echo "[5/6] Validating SSH configuration..."
sudo /usr/sbin/sshd -t

echo "[6/6] Checking Puppet idempotency..."

NOOP_OUTPUT="$(sudo puppet apply \
  --noop \
  --environmentpath="$(pwd)/environments" \
  --environment=production \
  --modulepath="$(pwd)/modules" \
  environments/production/manifests/site.pp 2>&1)"

echo "$NOOP_OUTPUT"

if echo "$NOOP_OUTPUT" | grep -qE "current_value .* should be|Would have triggered"; then
  echo
  echo "ERROR: Puppet detected configuration drift."
  exit 1
fi

echo
echo "Puppet validation completed successfully."
