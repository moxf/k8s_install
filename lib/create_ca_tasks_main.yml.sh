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

create_ca_tasks_main(){
    local file=$1
    local f_ca_app_dir=`dirname ${ca_app_dir}`
    cat >${file} <<EOF
-   name: copy src cfssl to remote host
    copy: src=${ca_source} dest=${f_ca_app_dir}
-   name: add cfssl env variable
    script: ${ca_init_script_name}
-   name: cert_generate
    script: ${ca_cert_generate_script_name}
    register: display
-   name: show cert_generate display
    debug: var=display verbosity=0
-   name: find cert dir
    find:
        paths: "${ca_app_dir}/cert/"
        patterns: "*"
        recurse: no
    register: file2fetch
-   name: fetch cert ==> localhost
    fetch:
        src: "{{ item.path }}"
        dest: "${local_cert_dir}/"
        flat: yes
    with_items: "{{ file2fetch.files }}"
EOF
}
