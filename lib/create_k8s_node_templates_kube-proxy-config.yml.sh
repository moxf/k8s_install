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

create_k8s_node_templates_kube-proxy-config(){
    local file=$1
    local config_dir=${k8s_node_app_dir}/config/kube-proxy
    cat >${file} <<EOF
apiVersion: kubeproxy.config.k8s.io/v1alpha1
bindAddress: {{ ansible_default_ipv4['address'] }}
clientConnection:
    kubeconfig: ${config_dir}/kube-proxy.kubeconfig
clusterCIDR: ${cluster_network}
healthzBindAddress: {{ ansible_default_ipv4['address'] }}:10256
hostnameOverride: {{ node_tag }}
kind: KubeProxyConfiguration
metricsBindAddress: {{ ansible_default_ipv4['address'] }}:10249
mode: "ipvs"
EOF
}
