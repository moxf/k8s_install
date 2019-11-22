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

create_etcd_templates_etcd(){
    local file=$1
    local cert_dir=${etcd_app_dir}/cert
    cat >${file} <<EOF

[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/coreos

[Service]
Type=notify
WorkingDirectory=${etcd_app_dir}
ExecStart=${etcd_app_dir}/bin/etcd \
  --name={{ etcd_tag }} \
  --cert-file=${cert_dir}/etcd.pem \
  --key-file=${cert_dir}/etcd-key.pem \
  --peer-cert-file=${cert_dir}/etcd.pem \
  --peer-key-file=${cert_dir}/etcd-key.pem \
  --trusted-ca-file=${cert_dir}/ca.pem \
  --peer-trusted-ca-file=${cert_dir}/ca.pem \
  --initial-advertise-peer-urls https://{{ ansible_default_ipv4['address'] }}:2380 \
  --listen-peer-urls https://{{ ansible_default_ipv4['address'] }}:2380 \
  --listen-client-urls https://{{ ansible_default_ipv4['address'] }}:2379,http://127.0.0.1:2379 \
  --advertise-client-urls https://{{ ansible_default_ipv4['address'] }}:2379 \
  --initial-cluster-token etcd-cluster-0 \
  --initial-cluster etcd01=https://{{ etcd01 }}:2380,etcd02=https://{{ etcd02 }}:2380,etcd03=https://{{ etcd03 }}:2380 \
  --initial-cluster-state new \
  --data-dir=${etcd_data_dir}
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target

EOF
}
