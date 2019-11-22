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

create_k8s_node_templates_kubelet(){
    local file=$1
    local mode_name=kubelet
    local cert_dir=${k8s_node_app_dir}/cert/${mode_name}
    local config_dir=${k8s_node_app_dir}/config/${mode_name}
    local log_dir=${k8s_log_dir}/${mode_name}
    cat >${file} <<EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
WorkingDirectory=${k8s_node_app_dir}
ExecStart=${k8s_node_app_dir}/bin/kubelet \
--bootstrap-kubeconfig=${config_dir}/kubelet-bootstrap.kubeconfig \
--cert-dir=${cert_dir} \
--client-ca-file=${cert_dir}/ca.pem \
--kubeconfig=${config_dir}/kubelet.kubeconfig \
--config=${config_dir}/${kubelet_config_file_name} \
--hostname-override={{ ansible_default_ipv4['address'] }} \
--pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google_containers/pause-amd64:3.1 \
--alsologtostderr=true \
--logtostderr=false \
--log-dir=${log_dir} \
--v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
}
