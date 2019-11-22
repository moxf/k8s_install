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

create_ca_files_init_ca(){
    local file=$1
    end_eof=EOF
    cat >${file} <<EOF
#!/bin/bash
source /etc/profile
chmod +x ${ca_app_dir}/bin/* 
sudo cat >/etc/profile.d/cfssl.sh <<EOF
export PATH=\\\$PATH:${ca_app_dir}/bin
${end_eof}
source /etc/profile.d/cfssl.sh
if [ $? -eq 0 ];then
    echo "add cfssl env variable ok"
else
    echo "add cfssl env variable faild"
    exit 7
fi
EOF
}
