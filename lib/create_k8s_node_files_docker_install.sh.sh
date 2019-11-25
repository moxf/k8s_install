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

create_k8s_node_files_docker_install(){
    local file=$1
    local end_eof=EOF
    local docker_data_dir=/data/docker
    cat >${file} <<EOF
#!/bin/bash
source /etc/profile
info_echo(){
    echo -e "\\033[32m [Info]: $1 \\033[0m"
}

#安装docker
install_docker(){

    info_echo "install docker"
    #配置epel源
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
    yum clean all
    rm -rf /var/cache/yum
    yum makecache
    #安装相关依赖
    yum -y install yum-utils device-mapper-persistent-data lvm2  container-selinux
    #配置yum仓库
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    yum makecache fast
    #安装指定版本docker
    yum -y install ${docker_version}
    #启动docker
    systemctl start docker
    systemctl enable docker
}

config_docker(){

    info_echo "config_docker"
    mkdir -p ${docker_data_dir}
    #使用清华大学镜像源
    sed -i 's@https://download.docker.com@https://mirrors.tuna.tsinghua.edu.cn/docker-ce@' /etc/yum.repos.d/docker-ce.repo
cat >/etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://registry.docker-cn.com"
  ],
  "graph": "${docker_data_dir}"
}
${end_eof}
    systemctl restart docker

}

install_docker
config_docker
EOF

}
