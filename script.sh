#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

IP="$(terraform output -raw public_ip)"
KEY="$HOME/Downloads/keysoracle/ssh-key-2026-09-28.key"

npm ci --prefix frontend --no-audit --no-fund
npm run build --prefix frontend

mkdir -p build
tar -czf build/site.tar.gz -C frontend/dist .

scp -o StrictHostKeyChecking=accept-new -i "$KEY" \
  build/site.tar.gz deploy/activate.sh deploy/nginx.conf ubuntu@"$IP":/tmp/

ssh -o StrictHostKeyChecking=accept-new -i "$KEY" ubuntu@"$IP" \
  "sudo bash /tmp/activate.sh"

echo "Página publicada: http://$IP/"
