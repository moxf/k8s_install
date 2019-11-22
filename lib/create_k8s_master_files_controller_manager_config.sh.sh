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

create_k8s_master_files_controller_manager_config(){
    local file=$1
cat > ${file} <<EOF
#!/bin/bash
source /etc/profile
cd ${k8s_master_app_dir}/config/kube-controller-manager 
kubectl config set-cluster kubernetes \
  --certificate-authority=${k8s_master_app_dir}/cert/kube-controller-manager/ca.pem \
  --embed-certs=true \
  --server=${apiserver_host} \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=${k8s_master_app_dir}/cert/kube-controller-manager/kube-controller-manager.pem \
  --client-key=${k8s_master_app_dir}/cert/kube-controller-manager/kube-controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-context system:kube-controller-manager \
  --cluster=kubernetes \
  --user=system:kube-controller-manager \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config use-context system:kube-controller-manager --kubeconfig=kube-controller-manager.kubeconfig
if [ -f ${k8s_master_app_dir}/config/kube-controller-manager/kube-controller-manager.kubeconfig ];then
    echo "kube-controller-manager.kubeconfig create ok"
else
    echo "kube-controller-manager.kubeconfig not found"
    exit 7
fi
EOF

}
