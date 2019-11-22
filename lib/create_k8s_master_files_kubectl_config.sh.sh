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

create_k8s_master_files_kubectl_config(){
    local script_path=$1
cat >${script_path} <<EOF
#!/bin/bash
source /etc/profile
cd ${k8s_master_app_dir}/cert/kubectl

kubectl config set-cluster kubernetes \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=${apiserver_host} \
  --kubeconfig=kubectl.kubeconfig

kubectl config set-credentials admin \
  --client-certificate=kubectl.pem \
  --client-key=kubectl-key.pem \
  --embed-certs=true \
  --kubeconfig=kubectl.kubeconfig

kubectl config set-context kubernetes \
  --cluster=kubernetes \
  --user=admin \
  --kubeconfig=kubectl.kubeconfig

kubectl config use-context kubernetes --kubeconfig=kubectl.kubeconfig
/bin/cp -f ${k8s_master_app_dir}/cert/kubectl/kubectl.kubeconfig ~/.kube/config

EOF
}
