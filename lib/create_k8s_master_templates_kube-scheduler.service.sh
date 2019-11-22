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

create_k8s_master_templates_kube-scheduler(){
    local file=$1
    local mode_name=kube-scheduler
    local cert_dir=${k8s_master_app_dir}/cert/${mode_name}
    local config_dir=${k8s_master_app_dir}/config/${mode_name}
    local log_dir=${k8s_log_dir}/${mode_name}
cat >${file} <<EOF
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=${k8s_master_app_dir}/bin/kube-scheduler \
  --address=127.0.0.1 \
  --kubeconfig=${config_dir}/kube-scheduler.kubeconfig \
  --leader-elect=true \
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
