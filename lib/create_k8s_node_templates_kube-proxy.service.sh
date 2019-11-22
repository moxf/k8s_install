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

create_k8s_node_templates_kube-proxy(){
    local file=$1
    local mode_name=kube-proxy
    local config_dir=${k8s_node_app_dir}/config/${mode_name}
    local bin_dir=${k8s_node_app_dir}/bin
    local log_dir=${k8s_log_dir}/${mode_name}
    cat >${file} <<EOF
[Unit]
Description=Kubernetes Kube-Proxy Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target

[Service]
WorkingDirectory=${k8s_node_app_dir}
ExecStart=${bin_dir}/kube-proxy \
  --config=${config_dir}/${kube_proxy_config_yml} \
  --alsologtostderr=true \
  --hostname-override={{ ansible_default_ipv4['address'] }} \
  --logtostderr=false \
  --log-dir=${log_dir} \
  --v=2
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
}
