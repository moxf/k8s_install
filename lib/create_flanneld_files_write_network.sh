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

create_flanneld_files_write_network(){
    local file=$1
    cat >${file} <<EOF
#!/bin/bash
source /etc/profile

cd ${etcd_app_dir}/cert
ETCDCTL_API=2 etcdctl  --endpoints=http://127.0.0.1:2379 --ca-file=ca.pem --cert-file=etcd.pem --key-file=etcd-key.pem rm /kubernetes/network/config '{"Network":"${cluster_network}","SubnetLen":${subnetlen},"Backend":{"Type":"vxlan"}}'
ETCDCTL_API=2 etcdctl  --endpoints=http://127.0.0.1:2379 --ca-file=ca.pem --cert-file=etcd.pem --key-file=etcd-key.pem rmdir /kubernetes/network

ETCDCTL_API=2 etcdctl  --endpoints=http://127.0.0.1:2379 --ca-file=ca.pem --cert-file=etcd.pem --key-file=etcd-key.pem mkdir /kubernetes/network
ETCDCTL_API=2 etcdctl  --endpoints=http://127.0.0.1:2379 --ca-file=ca.pem --cert-file=etcd.pem --key-file=etcd-key.pem mk /kubernetes/network/config '{"Network":"${cluster_network}","SubnetLen":${subnetlen},"Backend":{"Type":"vxlan"}}'
EOF
}
