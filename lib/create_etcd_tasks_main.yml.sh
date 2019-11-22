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

create_etcd_tasks_main(){
    local file=$1
    cat >${file} <<EOF
-   name: check ${remote_src_dir}
    file:
        path: "${remote_src_dir}"
        state: directory
        mode: 0755
-   name: check etcd_data_dir ==> ${etcd_data_dir}
    file:
        path: "${etcd_data_dir}"
        state: directory
        mode: 0755
-   name: unarchive ${etcd_package} to ${remote_src_dir}
    unarchive:
        src: "${etcd_package}"
        dest: "${remote_src_dir}"
-   name: init etcd
    script: ${etcd_init_file_name}
-   name: copy cert to etcd
    copy:
        src: "{{ item }}"
        dest: "${etcd_app_dir}/cert/"
    with_items:
        -   "${ca_pem}"
        -   "${ca_key_pem}"
        -   "${etcd_pem}"
        -   "${etcd_key_pem}"
-   name: copy etcd config to ==> /etc/systemd/system/${etcd_unit_file_name}
    template:
        src: ${etcd_unit_file_name}
        dest: /etc/systemd/system/${etcd_unit_file_name}
    notify:
        -   restart etcd
-   name: start etcd
    systemd:
        daemon_reload: true
        name: etcd
        state: started
        enabled: true
-   name: check etcd cluster-health
    shell: cd ${etcd_app_dir}/cert;sleep 15;etcdctl --ca-file=ca.pem --cert-file=etcd.pem --key-file=etcd-key.pem cluster-health
    when: etcd_tag == '${etcd_exec_command_host}'
    register: result
-   name: show check cluster-health result
    debug: var=result verbosity=0
EOF
}
