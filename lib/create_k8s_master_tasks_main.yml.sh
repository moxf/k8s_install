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

create_k8s_master_tasks_main(){
    local k8s_tasks_file=$1
cat >${k8s_tasks_file} <<EOF
-   name: check ${remote_src_dir}
    file:
        path: "${remote_src_dir}"
        state: directory
        mode: 0755
-   name: unarchive ${k8s_package}  to ${remote_src_dir}
    unarchive:
        src: "${k8s_package}"
        dest: "${remote_src_dir}"
-   name: init k8s_master
    script: ${k8s_master_init_script_name}
-   name: copy cert to kubectl
    copy:
        src: "{{ item }}"
        dest: "${k8s_master_app_dir}/cert/kubectl/"
    with_items:
        -   "${ca_pem}"
        -   "${ca_key_pem}"
        -   "${kubectl_pem}"
        -   "${kubectl_key_pem}"
-   name: create kubectl config
    script: ${kubectl_config_script_name}
    register: result
-   name: show config result
    debug: var=result verbosity=0
-   name: copy cert to apiserver
    copy:
        src: "{{ item }}"
        dest: "${k8s_master_app_dir}/cert/kube-apiserver/"
    with_items:
        -   "${ca_pem}"
        -   "${ca_key_pem}"
        -   "${kube_apiserver_pem}"
        -   "${kube_apiserver_key_pem}"
        -   "${kube_proxy_pem}"
        -   "${kube_proxy_key_pem}"
-   name: copy config to apiserver
    copy:
        src: ${apiserver_encryption_config_name}
        dest: "${k8s_master_app_dir}/config/kube-apiserver/"
-   name: copy apiserver unit file to ==> /etc/systemd/system/kube-apiserver.service
    template:
        src: ${apiserver_unit_file_name}
        dest: /etc/systemd/system/kube-apiserver.service
    notify:
        -   restart kube-apiserver
-   name: start kube-apiserver
    systemd:
        daemon_reload: true
        name: kube-apiserver
        state: started
        enabled: true
-   name: check cluster status
    shell: kubectl cluster-info 
    register: result
-   name: show cluster status
    debug:
        var: result
        verbosity: 0
-   name: add kubernetes cert auth 
    shell: kubectl create clusterrolebinding kube-apiserver:kubelet-apis --clusterrole=system:kubelet-api-admin --user kubernetes
    register: resultl
    when:
        master_tag == '${exec_command_host}'        
-   name: show add kubernetes cert auth result
    debug:
        var: result
        verbosity: 0

-   name: copy cert to controller-manager
    copy:
        src: "{{ item }}"
        dest: "${k8s_master_app_dir}/cert/kube-controller-manager/"
    with_items:
        -   "${ca_pem}"
        -   "${ca_key_pem}"
        -   "${kube_controller_manager_pem}"
        -   "${kube_controller_manager_key_pem}"
-   name: create controller-manager config
    script: ${controller_manager_config_script_name}
    register: result
-   name: show config result
    debug: var=result verbosity=0
-   name: copy controller-manager unit file to ==>  /etc/systemd/system/kube-controller-manager.service
    template:
        src: ${controller_manager_unit_file_name}
        dest: /etc/systemd/system/kube-controller-manager.service
    notify:
        -   restart kube-controller-manager
-   name: start kube-controller-manager
    systemd:
        daemon_reload: true
        name: kube-controller-manager
        state: started
        enabled: true 

-   name: copy cert to scheduler
    copy:
        src: "{{ item }}"
        dest: "${k8s_master_app_dir}/cert/kube-scheduler"
    with_items:
        -   "${ca_pem}"
        -   "${ca_key_pem}"
        -   "${kube_scheduler_pem}"
        -   "${kube_scheduler_key_pem}"   
-   name: create scheduler config
    script: ${scheduler_config_script_name}
    register: result
-   name: show config result
    debug: 
        var: result 
        verbosity: 0
-   name: copy scheduler uniit file to ==> /etc/systemd/system/kube-scheduler.service
    template:
        src: ${scheduler_unit_file_name}
        dest: /etc/systemd/system/kube-scheduler.service
    notify:
        -   restart kube-scheduler
-   name: start kube-scheduler
    systemd:
        daemon_reload: true
        name: kube-scheduler
        state: started
        enabled: true

-   name: create kubelet bootstrap config
    script: ${kubelet_bootstrap_config_script_name} node
    when:
        master_tag == '${exec_command_host}'
-   name: fetch kubelet bootstrap config to src
    fetch: 
        src: ${k8s_master_app_dir}/config/kube-apiserver/kubelet-bootstrap.kubeconfig
        dest: ${package_src}/kubelet-bootstrap.kubeconfig
        flat: yes
    when:
        master_tag == '${exec_command_host}'
-   name: create kubelet clusterrolebingding
    script: ${kubelet_rolesbinding_file_name}
    register: result
    when:
        master_tag == '${exec_command_host}'
-   name: show kubelet_rolesbinding result
    debug:
        var: result
        verbosity: 0
-   name: copy approve_kubelet_csr_file to ${k8s_master_app_dir}/config/kube-apiserver
    copy:
        src: ${approve_kubelet_csr_file_name}
        dest: ${k8s_master_app_dir}/config/kube-apiserver/
    when: 
        master_tag == '${exec_command_host}'
-   name: exec approve-csr
    shell: cd ${k8s_master_app_dir}/config/kube-apiserver/;kubectl apply -f ${approve_kubelet_csr_file_name}
    when:
        master_tag == '${exec_command_host}'
    register: result
-   name: show approve-csr result
    debug: 
        var: result
        verbosity: 0
-   name: copy ${apiserver_kubelet_rbac_file_name} to  ${k8s_master_app_dir}/config/kube-apiserver
    copy:
        src: ${apiserver_kubelet_rbac_file_name}
        dest: ${k8s_master_app_dir}/config/kube-apiserver/
-   name: create apiserver_kubelet_rbac
    command: kubectl apply -f ${k8s_master_app_dir}/config/kube-apiserver/${apiserver_kubelet_rbac_file_name}
    register: result
-   name: show create apiserver_kubelet_rbac result
    debug:
        var: result
        verbosity: 0
-   name: create kube-proxy config
    script: ${kube_proxy_config_script_name}
    when: 
        master_tag == '${exec_command_host}'
-   name: fetch kube-proxy config to src
    fetch: 
        src: ${k8s_master_app_dir}/config/kube-apiserver/kube-proxy.kubeconfig
        dest: ${package_src}/kube-proxy.kubeconfig
        flat: yes
    when:
        master_tag == '${exec_command_host}'
EOF
}
