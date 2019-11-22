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

create_k8s_node_tasks_main(){
    local k8s_tasks_file=$1
cat >${k8s_tasks_file} <<EOF
-   name: install docker
    script: ${docker_install_script_name} 
-   name: config docker support flannel
    script: ${config_docker_flannel_script_name}
-   name: check ${remote_src_dir}
    file:
        path: "${remote_src_dir}"
        state: directory
        mode: 0755
-   name: unarchive ${k8s_package}  to ${remote_src_dir}
    unarchive:
        src: "${k8s_package}"
        dest: "${remote_src_dir}"
-   name: init k8s_node
    script: ${k8s_node_init_script_name}
-   name: copy cert to kubectl
    copy:
        src: "{{ item }}"
        dest: "${k8s_node_app_dir}/cert/kubelet/"
    with_items:
        -   "${ca_pem}"
        -   "${ca_key_pem}"
-   name: copy kubelet bootstrap config ==> ${k8s_node_app_dir}/config/kubelet/
    copy:
        src: ${package_src}/kubelet-bootstrap.kubeconfig
        dest: ${k8s_node_app_dir}/config/kubelet/
-   name: copy kubelet config ==> ${k8s_node_app_dir}/config/kubelet/
    template:
        src: "${kubelet_config_file_name}"
        dest: "${k8s_node_app_dir}/config/kubelet/${kubelet_config_file_name}"
-   name: copy kubelet unit file ==> /etc/systemd/system/kubelet.service
    template:
        src: "${kubelet_unit_file_name}" 
        dest: /etc/systemd/system/kubelet.service
    notify:
        -   restart kubelet
-   name: start kubelet
    systemd:
        daemon_reload: true
        name: kubelet
        state: started
        enabled: true
-   name: install kube-proxy devel
    yum: 
        name: ['conntrack', 'ipvsadm', 'jq', 'curl', 'libseccomp'] 
        state: installed
-   name: load ip_vs
    command: /usr/sbin/modprobe ip_vs
-   name: copy ${package_src}/kube-proxy.kubeconfig ==>${k8s_node_app_dir}/config/kube-proxy/
    copy: 
        src: ${package_src}/kube-proxy.kubeconfig
        dest: ${k8s_node_app_dir}/config/kube-proxy/
-   name: copy kube-proxy config yml==> ${k8s_node_app_dir}/config/kube-proxy
    template:
        src: ${kube_proxy_config_yml}
        dest: ${k8s_node_app_dir}/config/kube-proxy/${kube_proxy_config_yml}
-   name: copy kube-proxy unit == /etc/systemd/system/kube-proxy.service
    template:
        src: ${kube_proxy_unit_file_name}
        dest: /etc/systemd/system/${kube_proxy_unit_file_name} 
    notify:
        -   restart kube-proxy
-   name: start kube-proxy
    systemd:
        daemon_reload: true
        name: kube-proxy
        state: started
        enabled: true

EOF
}
