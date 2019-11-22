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

create_k8s_master_files_scheduler_config(){
    local file=$1
    local mode_name=kube-scheduler
    local cert_dir=${k8s_master_app_dir}/cert/${mode_name}
    local config_dir=${k8s_master_app_dir}/config/${mode_name}
cat >${file} <<EOF
#!/bin/bash
source /etc/profile
cd ${config_dir}
kubectl config set-cluster kubernetes \
  --certificate-authority=${cert_dir}/ca.pem \
  --embed-certs=true \
  --server=${apiserver_host} \
  --kubeconfig=${mode_name}.kubeconfig
  
kubectl config set-credentials system:${mode_name} \
  --client-certificate=${cert_dir}/${mode_name}.pem \
  --client-key=${cert_dir}/${mode_name}-key.pem \
  --embed-certs=true \
  --kubeconfig=${mode_name}.kubeconfig
  
kubectl config set-context system:${mode_name} \
  --cluster=kubernetes \
  --user=system:${mode_name} \
  --kubeconfig=${mode_name}.kubeconfig
  
kubectl config use-context system:${mode_name} --kubeconfig=${mode_name}.kubeconfig
if [ -f ${config_dir}/${mode_name}.kubeconfig ];then
    echo "create  ${config_dir}/${mode_name}.kubeconfig ok"
else
    echo "create ${config_dir}/${mode_name}.kubeconfig faild"
    exit 7
fi
EOF
}
