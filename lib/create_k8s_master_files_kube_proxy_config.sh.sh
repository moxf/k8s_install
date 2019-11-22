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

create_k8s_master_files_kube_proxy_config(){
    local file=$1
    local config_dir=${k8s_master_app_dir}/config/kube-apiserver
    local cert_dir=${k8s_master_app_dir}/cert/kube-apiserver
    cat >${file} <<EOF
#!/bin/bash
source /etc/profile
cd ${config_dir}
kubectl config set-cluster kubernetes \
  --certificate-authority=${cert_dir}/ca.pem \
  --embed-certs=true \
  --server=${apiserver_host} \
  --kubeconfig=kube-proxy.kubeconfig
  
kubectl config set-credentials kube-proxy \
  --client-certificate=${cert_dir}/kube-proxy.pem \
  --client-key=${cert_dir}/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig
  
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig
  
kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
if [ -f ${config_dir}/kube-proxy.kubeconfig ];then
    echo "create kube-proxy.kubeconfig ok"
else
    echo "create kube-proxy.kubeconfig faild"
    exit 7
fi
EOF
}
