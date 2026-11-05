#!/bin/bash
set -e

apt-get update
apt-get install -y nginx
systemctl enable --now nginx
