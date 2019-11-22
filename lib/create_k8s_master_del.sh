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

create_k8s_master_del(){
    local file=$1
    app_dir=${k8s_master_app_dir}
    f_app_dir=`dirname ${k8s_master_app_dir}`
cat >${file} <<EOF
#!/bin/bash
source /etc/profile
mode_name_set=('kube-apiserver' 'kube-controller_manager' 'kube-scheduler')
for mode_name in \${mode_name_set[*]};do
    if [ -f /etc/systemd/system/\${mode_name}.service ];then
        systemctl stop \${mode_name}
        rm -f /etc/systemd/system/\${mode_name}.service
    fi
    if [ -d /data/\${mode_name} ];then
        cd /data && /bin/rm -rf \${mode_name}
        echo "cd /data && /bin/rm -rf \${mode_name}"
    fi
done

pkill -9 kube-apiserver 
pkill -9 kube-controller_manager 
pkill -9 kube-scheduler

if [ -z "${app_dir}"  ];then
    echo "erro! app_dir is null"
    exit 7
fi
f_app_dir=${f_app_dir}
if [ ${f_app_dir} != '/' ];then
    cd ${f_app_dir} && /bin/rm -rf ${mode_name}
    echo "cd ${f_app_dir} && /bin/rm -rf ${mode_name}"
fi
EOF

}
