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

create_flanneld_tasks_main(){
    local file=$1
    cat >${file} <<EOF
-   name: check ${remote_src_dir}
    file:
        path: "${remote_src_dir}"
        state: directory
        mode: 0755
-   name: unarchive ${flanneld_package} to ${remote_src_dir}
    unarchive:
        src: "${flanneld_package}"
        dest: "${remote_src_dir}"
-   name: init flanneld
    script: ${flanneld_init_file_name}
-   name: copy cert to flanneld
    copy:
        src: "{{ item }}"
        dest: "${flanneld_app_dir}/cert/"
    with_items:
        -   "${ca_pem}"
        -   "${ca_key_pem}"
        -   "${flanneld_pem}"
        -   "${flanneld_key_pem}"
-   name: write network info to etcd
    script: ${flanneld_write_network_file_name}
    when: flanneld_tag == '${etcd_exec_command_host}'
    register: result
-   name: dislpay write network result
    debug: var=result verbosity=0
-   debug:
        msg: "flanneld_tag ${etcd_exec_command_host}"
-   name: copy flanneld config to ==> /etc/systemd/system/${flanneld_unit_file_name}
    template:
        src: ${flanneld_unit_file_name}
        dest: /etc/systemd/system/${flanneld_unit_file_name}
    notify:
        -   restart flanneld
-   name: start flanneld
    systemd:
        daemon_reload: true
        name: flanneld
        state: started
        enabled: true
EOF
}
