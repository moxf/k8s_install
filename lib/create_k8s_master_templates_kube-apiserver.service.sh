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

create_k8s_master_templates_kube-apiserver(){
    local file=$1
    local mode_name=kube-apiserver
    local cert_dir=${k8s_master_app_dir}/cert/${mode_name}
    local config_dir=${k8s_master_app_dir}/config/${mode_name}
cat > ${file} << EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target

[Service]
ExecStart=${k8s_master_app_dir}/bin/kube-apiserver \
  --anonymous-auth=false \
  --experimental-encryption-provider-config=${config_dir}/encryption-config.yaml \
  --advertise-address={{ ansible_default_ipv4['address'] }} \
  --bind-address={{ ansible_default_ipv4['address'] }} \
  --insecure-port=0 \
  --authorization-mode=Node,RBAC \
  --runtime-config=api/all \
  --enable-bootstrap-token-auth \
  --service-cluster-ip-range=${service_cluster_ip_range} \
  --service-node-port-range=30000-32700 \
  --tls-cert-file=${cert_dir}/kube-apiserver.pem \
  --tls-private-key-file=${cert_dir}/kube-apiserver-key.pem \
  --client-ca-file=${cert_dir}/ca.pem \
  --kubelet-client-certificate=${cert_dir}/kube-apiserver.pem \
  --kubelet-client-key=${cert_dir}/kube-apiserver-key.pem \
  --service-account-key-file=${cert_dir}/ca-key.pem \
  --etcd-cafile=${cert_dir}/ca.pem \
  --etcd-certfile=${cert_dir}/kube-apiserver.pem \
  --etcd-keyfile=${cert_dir}/kube-apiserver-key.pem \
  --etcd-servers=https://{{ etcd01 }}:2379,https://{{ etcd02 }}:2379,https://{{ etcd03 }}:2379 \
  --enable-swagger-ui=true \
  --allow-privileged=true \
  --apiserver-count=3 \
  --audit-log-maxage=30 \
  --audit-log-maxbackup=3 \
  --audit-log-maxsize=100 \
  --audit-log-path=${k8s_log_dir}/kube-apiserver/kube-apiserver-audit.log \
  --event-ttl=1h \
  --alsologtostderr=true \
  --logtostderr=false \
  --log-dir=${k8s_log_dir}/kube-apiserver \
  --requestheader-client-ca-file=${cert_dir}/ca.pem \
  --requestheader-allowed-names=aggregator \
  --requestheader-extra-headers-prefix=X-Remote-Extra- \
  --requestheader-group-headers=X-Remote-Group \
  --requestheader-username-headers=X-Remote-User \
  --proxy-client-cert-file=${cert_dir}/kube-proxy.pem \
  --proxy-client-key-file=${cert_dir}/kube-proxy-key.pem \
  --v=2
Restart=on-failure
RestartSec=5
Type=notify
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
}
