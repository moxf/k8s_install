# -------------------------------------------------------------------------------
# Revision:    1.0
# Date:        2019/11/21
# Author:      mox
# Email:       827897564@qq.com
# Description: Script to install the kubernets system
# -------------------------------------------------------------------------------
# License:     GPL
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# you should have received a copy of the GNU General Public License
# along with this program (or with Nagios);
#
# Credits go to Ethan Galstad for coding Nagios
# If any changes are made to this script, please mail me a copy of the changes
# -------------------------------------------------------------------------------

create_flanneld_templates_flanneld(){
    local file=$1
    local cert_dir=${flanneld_app_dir}/cert
    local bin_dir=${flanneld_app_dir}/bin
    cat >${file} <<EOF
[Unit]
Description=Flanneld overlay address etcd agent
After=network.target
After=network-online.target
Wants=network-online.target
After=etcd.service
Before=docker.service

[Service]
Type=notify
ExecStart=${bin_dir}/flanneld \
  -etcd-cafile=${cert_dir}/ca.pem \
  -etcd-certfile=${cert_dir}/flanneld.pem \
  -etcd-keyfile=${cert_dir}/flanneld-key.pem \
  -etcd-endpoints=https://{{ etcd01 }}:2379,https://{{ etcd02 }}:2379,https://{{ etcd03 }}:2379 \
  -etcd-prefix=/kubernetes/network
ExecStartPost=${bin_dir}/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/docker
Restart=on-failure

[Install]
WantedBy=multi-user.target
RequiredBy=docker.service
EOF
}
