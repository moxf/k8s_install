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

create_ca_files_cert_generate(){
    local file=$1
    local cert_dir=${ca_app_dir}/cert

    cat >${file} <<EOF
#!/bin/bash
source /etc/profile
svr_list=("etcd" "flanneld" "kubectl" "kube-apiserver" "kube-controller-manager" "kube-scheduler" "kube-proxy")

cd ${cert_dir}
echo "init ca server"
cfssl gencert -initca ca-csr.json | cfssljson -bare ca

for svr in \${svr_list[*]};do
    cfssl gencert -ca=ca.pem \
        -ca-key=ca-key.pem \
        -config=ca-config.json \
        -profile=kubernetes \${svr}-csr.json|cfssljson -bare \${svr}
    if [ \$? -eq 0 ];then
        echo "\${svr} cert ok"
    else    
        echo "\${svr} cert faild"
        exit 7
    fi
done
EOF
}
