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

create_k8s_master_files_kubelet_bootstrap_config(){
    local file=$1
    local mode_name=kube-apiserver
    local cert_dir=${k8s_master_app_dir}/cert/${mode_name}
    local config_dir=${k8s_master_app_dir}/config/${mode_name}
    
    cat >${file} <<EOF
#!/bin/bash
source /etc/profile
host_tag=\$1
cd ${config_dir}
export BOOTSTRAP_TOKEN=\$(kubeadm token create \
  --description kubelet-bootstrap-token \
  --groups system:bootstrappers:\${host_tag} \
  --kubeconfig ~/.kube/config)

kubectl config set-cluster kubernetes \
  --certificate-authority=${cert_dir}/ca.pem \
  --embed-certs=true \
  --server=${apiserver_host}\
  --kubeconfig=kubelet-bootstrap.kubeconfig

kubectl config set-credentials kubelet-bootstrap \
  --token=\${BOOTSTRAP_TOKEN} \
  --kubeconfig=kubelet-bootstrap.kubeconfig


kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet-bootstrap \
  --kubeconfig=kubelet-bootstrap.kubeconfig

kubectl config use-context default --kubeconfig=kubelet-bootstrap.kubeconfig

if [ -f ${config_dir}/kubelet-bootstrap.kubeconfig ];then
    echo "create kubelet bootstrap config ok"
else
    echo "create kubelet bootstrap config faild"
    exit 7
fi

EOF
}
