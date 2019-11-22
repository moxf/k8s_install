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

create_k8s_node_files_config_docker_flannel(){
    local file=$1
cat >${file} <<EOF
#!/bin/bash
source /etc/profile
sed -i '/^Type=notify/a\EnvironmentFile=/run/flannel/docker' /etc/systemd/system/multi-user.target.wants/docker.service
sed -i 's@ExecStart=/usr/bin/dockerd.*@ExecStart=/usr/bin/dockerd $DOCKER_NETWORK_OPTIONS@' /etc/systemd/system/multi-user.target.wants/docker.service

sed -i '/^Type=notify/a\EnvironmentFile=/run/flannel/docker' /usr/lib/systemd/system/docker.service
sed -i 's@ExecStart=/usr/bin/dockerd.*@ExecStart=/usr/bin/dockerd $DOCKER_NETWORK_OPTIONS@' /usr/lib/systemd/system/docker.service

systemctl daemon-reload
systemctl restart docker
EOF

}
