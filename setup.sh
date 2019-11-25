#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    setup.sh
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


source /etc/profile
shell_dir=`cd $(dirname $0);pwd`
source ${shell_dir}/config.ini
host_file=${shell_dir}/hosts
log_dir=${shell_dir}/log
mkdir -p ${log_dir}
log_file=${log_dir}/setup.log
declare -A full_host_set
start_time=`date +%s`


load_lib(){
    lib_dir=${shell_dir}/lib
    lib_main=${lib_dir}/main.sh
    if [ -f ${lib_main} ];then
        rm -f ${lib_main}
    fi
    for lib in `ls ${lib_dir}|grep ".sh$"`;do
        echo "source ${lib_dir}/${lib}" >>${lib_main}
    done
    source ${lib_main}
}


log(){
    DATE_OUT="date +%F-%H:%M:%S"
    if [ $# -gt 1  ];then
        echo -e "\\033[32m [`$DATE_OUT`]: $1 \\033[0m"
        echo "[`$DATE_OUT`]: $1" >>${log_file}
    else
        echo "[`$DATE_OUT`]: $1" >>${log_file}
    fi
}


err_log(){
    DATE_OUT="date +%F-%H:%M:%S"
    if [ $# -gt 1  ];then
        echo -e "\\033[31m [`$DATE_OUT`]: erro! $1 \\033[0m"
        echo "[`$DATE_OUT`]: $1" >>${log_file}
    else
        echo "[`$DATE_OUT`]: $1" >>${log_file}
    fi
    exit 7
}


check_package(){
    package=$1
    if [ ! -f ${package} ];then
        err_log "${package} not found" yes
    fi
}


write_hosts(){

    #获取全部主机信息
    for host_flag in ${!k8s_master_host_set[*]};do
        full_host_set[${k8s_master_host_set[${host_flag}]}]=${host_flag}
    done
    for host_flag in ${!k8s_node_host_set[*]};do
        full_host_set[${k8s_node_host_set[${host_flag}]}]=${host_flag}
    done
    for host_flag in ${!etcd_host_set[*]};do
        full_host_set[${etcd_host_set[${host_flag}]}]=${host_flag}
    done    

    #写入ca==>hosts
    echo '[ca]' >${host_file}
    echo ${ca_host} >>${host_file}

    #写入etcd==>hosts
    local etcd_count=0
    echo "" >>${host_file}
    echo "[etcd]" >>${host_file}
    for host_flag in ${!etcd_host_set[*]};do
        let etcd_count+=1
        echo  ${etcd_host_set[${host_flag}]} etcd_tag=${host_flag} >>${host_file}
        if [ ${etcd_count} -eq 1 ];then
            etcd_exec_command_host=${host_flag}
        fi
    done 
    echo "[etcd:vars]" >>${host_file}
    for host_flag in ${!etcd_host_set[*]};do
        echo ${host_flag}=${etcd_host_set[${host_flag}]}  >>${host_file}
    done

    #写入flanneld ==> hosts
    echo "" >>${host_file}
    echo "[flanneld]" >>${host_file}
    for host in ${!full_host_set[*]};do
        echo "${host} flanneld_tag=${full_host_set[${host}]}" >>${host_file}
    done
    echo "[flanneld:vars]" >>${host_file}
    for host_flag in ${!etcd_host_set[*]};do
        echo ${host_flag}=${etcd_host_set[${host_flag}]}  >>${host_file}
    done

    #写入k8s_master==>hosts
    local master_count=0
    echo "" >>${host_file}
    echo "[k8s_master]" >>${host_file}
    for host_flag in ${!k8s_master_host_set[*]};do
        let master_count+=1
        echo  ${k8s_master_host_set[${host_flag}]} master_tag=${host_flag} >>${host_file}
        if [ ${master_count} -eq 1 ];then
            exec_command_host=${host_flag}
        fi
    done 
    echo "[k8s_master:vars]" >>${host_file}
    for host_flag in ${!etcd_host_set[*]};do
        echo ${host_flag}=${etcd_host_set[${host_flag}]}  >>${host_file}
    done

    #node
    echo "" >>${host_file}
    echo "[k8s_node]" >>${host_file}
        for host_flag in ${!k8s_node_host_set[*]};do
        echo  ${k8s_node_host_set[${host_flag}]} node_tag=${host_flag} >>${host_file}
    done

}


load_var(){
    ca_source=${shell_dir}/src/cfssl
    local_cert_dir=${ca_source}/cert
    package_src=${shell_dir}/src
    etcd_package=${package_src}/${etcd_package_name}
    flanneld_package=${package_src}/${flanneld_package_name}
    k8s_package=${package_src}/${k8s_package_name}
    mkdir -p ${local_cert_dir}

    #key名称
    mode_set=('ca' 'etcd' 'flanneld' 'kubectl' 'kube-apiserver' 'kube-proxy' 'kube-controller-manager' 'kube-scheduler')
    declare -A mode_key_name_set
    for mode_name in ${mode_set[*]};do
        mode_key_name_set[${mode_name}_pem]=${local_cert_dir}/${mode_name}.pem
        mode_key_name_set[${mode_name}_key_pem]=${local_cert_dir}/${mode_name}-key.pem
    done

    ca_pem=${mode_key_name_set[ca_pem]}
    ca_key_pem=${mode_key_name_set[ca_key_pem]}
    etcd_pem=${mode_key_name_set[etcd_pem]}
    etcd_key_pem=${mode_key_name_set[etcd_key_pem]}
    flanneld_pem=${mode_key_name_set[flanneld_pem]}
    flanneld_key_pem=${mode_key_name_set[flanneld_key_pem]}
    kubectl_pem=${mode_key_name_set[kubectl_pem]}
    kubectl_key_pem=${mode_key_name_set[kubectl_key_pem]}
    kube_apiserver_pem=${mode_key_name_set[kube-apiserver_pem]}
    kube_apiserver_key_pem=${mode_key_name_set[kube-apiserver_key_pem]}
    kube_proxy_pem=${mode_key_name_set[kube-proxy_pem]}
    kube_proxy_key_pem=${mode_key_name_set[kube-proxy_key_pem]}
    kube_controller_manager_pem=${mode_key_name_set[kube-controller-manager_pem]}
    kube_controller_manager_key_pem=${mode_key_name_set[kube-controller-manager_key_pem]}
    kube_scheduler_pem=${mode_key_name_set[kube-scheduler_pem]}
    kube_scheduler_key_pem=${mode_key_name_set[kube-scheduler_key_pem]}
}


create_del_script(){

    local mode_name=$1
    case $mode_name in
        etcd)
            local app_dir=${etcd_app_dir}
            ;;
        flanneld)
            local app_dir=${flanneld_app_dir}
            ;;
        *)
            echo "unknow mode_name:${mode_name}"
            ;;
    esac
    mkdir -p ${shell_dir}/roles/del/
    local f_app_dir=`dirname ${app_dir}`

cat >${shell_dir}/roles/del/del_${mode_name}.sh <<EOF
#!/bin/bash
source /etc/profile
app_dir=${app_dir}
systemctl stop ${mode_name}
pid=\`ps -ef |grep "${app_dir}/bin/${mode_name}"|grep -v grep |awk '{print \$2}'\`
if [ -n \${pid} ];then
    kill -9 \${pid}
    echo "kill -9 \${pid}"
fi
if [ -z "${app_dir}"  ];then
    echo "erro! app_dir is null"
    exit 7
fi
f_app_dir=${f_app_dir}
if [ ${f_app_dir} != '/' ];then
    cd ${f_app_dir} && /bin/rm -rf ${mode_name}
    echo "cd ${f_app_dir} && /bin/rm -rf ${mode_name}"
fi
rm -f /etc/systemd/system/${mode_name}.service
if [ -d /data/${mode_name} ];then
    cd /data && /bin/rm -rf ${mode_name}
    echo "cd /data && /bin/rm -rf ${mode_name}"
fi

EOF

}


create_csr(){
    mode_name=$1
    hosts=$2
    hosts_sum=$3
    csr_file=${local_cert_dir}/${mode_name}-csr.json
    log "create_csr mode_name:${mode_name} hosts:${hosts} hosts_sum:${hosts_sum} csr_file:${csr_file}"
    case ${mode_name} in
        ca)
            cn=kubernetes
            o=ca
            ou=ops
            ;;
        etcd)
            cn=${mode_name}
            o=kubernetes
            ou=System
            ;;
        flanneld)
            cn=flanneld
            o=kubernetes
            ou=ops
            ;;
        kubectl)
            cn=admin
            o='system:masters'
            ou=ops
            ;;
        kube-apiserver)
            cn=kubernetes
            o=kubernetes
            ou=ops
            ;;
        kube-controller-manager)
            cn='system:kube-controller-manager'
            o="system:kube-controller-manager"
            ou=ops
            ;;
        kube-scheduler)
            cn='system:kube-scheduler'
            o='system:kube-scheduler'
            ou=:ops
            ;;
        kube-proxy)
            cn='system:kube-proxy'
            o='kubernetes'
            ou=ops
            ;;
        *)
            echo "erro! unknow modo_name:$mode_name"
            ;;
    esac
            
if [ -z "${hosts}" ];then
    cat >${csr_file} <<EOF
{
  "CN": "${cn}",

  "key": {
        "algo": "rsa",
        "size": 2048
  },

  "names": [
    {
        "C": "CN",
        "ST": "GD",
        "L": "guangzhou",
        "O": "${o}",
        "OU": "${ou}"
    }
  ]
}
EOF
else
    count=0
    if [ ${mode_name} == 'kube-apiserver' ];then
        echo -e "{\n    \"hosts\": [\n       \"127.0.0.1\", " >${csr_file}
        echo "       \"kubernetes\",
       \"kubernetes.default\",
       \"kubernetes.default.svc\",
       \"kubernetes.default.svc.cluster\",
       \"kubernetes.default.svc.cluster.local\"," >>${csr_file}
    else
        echo -e "{\n    \"hosts\": [\n       \"127.0.0.1\"," >${csr_file}
    fi
    for host in ${hosts};do
        let count+=1
        if [ ${count} -eq ${hosts_sum} ];then
            echo -e "       \"${host}\"\n ]," >>${csr_file}
        else
            echo -e "       \"${host}\", " >>${csr_file}
        fi
   done 

    cat >>${csr_file} <<EOF
  "CN": "${cn}",

  "key": {
        "algo": "rsa",
        "size": 2048
  },

  "names": [
    {
        "C": "CN",
        "ST": "GD",
        "L": "guangzhou",
        "O": "${o}",
        "OU": "${ou}"
    }
  ]
}
EOF

fi
}


create_csr_full(){

    ca_config_file=${local_cert_dir}/ca-config.json
    create_ca_config ${ca_config_file} 
    create_csr ca 
    create_csr etcd "${etcd_host_set[*]}"  ${#etcd_host_set[*]}
    create_csr flanneld
    create_csr kubectl
    
    apiserver_host_addr=`echo ${apiserver_host}|awk -F':|/' '{print $4}'`
    full_host_set[${apiserver_host_addr}]=apiserver_host_addr
    create_csr kube-apiserver "${!full_host_set[*]}" ${#full_host_set[@]}
    create_csr kube-controller-manager "${k8s_master_host_set[*]}" ${#k8s_master_host_set[@]}
    create_csr kube-scheduler "${k8s_master_host_set[*]}" ${#k8s_master_host_set[@]}
    create_csr kube-proxy
}


create_ca_config(){
    local file=$1
    cat >${file} <<EOF
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "87600h"
      }
    }
  }
}
EOF
}


init_ansible_roles(){

    declare -A handler_file_set
    declare -A  ca_file_set
    declare -A etcd_file_set
    declare -A flanneld_file_set
    declare -A k8s_master_file_set
    declare -A k8s_node_file_set

    local mode_name=$1
    local roles_dir=${shell_dir}/roles/${mode_name}
    case ${mode_name} in
        ca)
            ca_init_script_name=init_ca.sh 
            ca_cert_generate_script_name=cert_generate.sh
            ca_file_set=([files]="${ca_init_script_name},${ca_cert_generate_script_name}" [tasks]='main.yml')
            for key in ${!ca_file_set[*]};do
                handler_file_set[${key}]=${ca_file_set[${key}]}
            done
            ;;
        etcd)
            etcd_init_file_name=init_etcd.sh
            etcd_unit_file_name=etcd.service
            etcd_file_set=([files]="${etcd_init_file_name}" [handlers]='main.yml' [tasks]='main.yml' [templates]="${etcd_unit_file_name}")
            for key in ${!etcd_file_set[*]};do
                handler_file_set[${key}]=${etcd_file_set[${key}]}
            done
            ;;
        flanneld)
            
            flanneld_init_file_name=init_flanneld.sh
            flanneld_write_network_file_name=write_network.sh
            flanneld_unit_file_name=flanneld.service
            flanneld_file_set=([files]="${flanneld_init_file_name},${flanneld_write_network_file_name}" [handlers]='main.yml' [tasks]='main.yml' [templates]="${flanneld_unit_file_name}")
            for key in ${!flanneld_file_set[*]};do
                handler_file_set[${key}]=${flanneld_file_set[${key}]}
            done       
            ;;
        k8s_master)
            k8s_master_init_script_name=init_k8s_master.sh 
            kubectl_config_script_name=kubectl_config.sh
            apiserver_encryption_config_name=encryption-config.yaml
            apiserver_unit_file_name=kube-apiserver.service 
            controller_manager_config_script_name=controller_manager_config.sh
            controller_manager_unit_file_name=kube-controller-manager.service
            scheduler_config_script_name=scheduler_config.sh
            scheduler_unit_file_name=kube-scheduler.service 
            kubelet_bootstrap_config_script_name=kubelet_bootstrap_config.sh
            approve_kubelet_csr_file_name=kubelet_approve_csr.yml
            kubelet_rolesbinding_file_name=kubelet_rolesbinding.sh
            apiserver_kubelet_rbac_file_name=apiserver_kubelet_rbac.yml
            kube_proxy_config_script_name=kube_proxy_config.sh
            k8s_master_del_script=${shell_dir}/roles/del/del_k8s_master.sh
            k8s_master_file_set=([files]="${k8s_master_init_script_name},${kubectl_config_script_name},${apiserver_encryption_config_name},${controller_manager_config_script_name},${scheduler_config_script_name},${kubelet_bootstrap_config_script_name},${approve_kubelet_csr_file_name},${kubelet_rolesbinding_file_name},${apiserver_kubelet_rbac_file_name},${kube_proxy_config_script_name}" [templates]="${apiserver_unit_file_name},${controller_manager_unit_file_name},${scheduler_unit_file_name}" [tasks]='main.yml' [handlers]='main.yml')
            
            create_k8s_master_del ${k8s_master_del_script}
            for key in ${!k8s_master_file_set[*]};do
                handler_file_set[${key}]=${k8s_master_file_set[${key}]}
            done       
            ;;
        k8s_node)
            docker_install_script_name=docker_install.sh
            config_docker_flannel_script_name=config_docker_flannel.sh
            k8s_node_init_script_name=init_node.sh 
            kubelet_config_file_name=kubelet_config.json 
            kubelet_unit_file_name=kubelet.service
            kube_proxy_config_yml=kube-proxy-config.yaml
            kube_proxy_unit_file_name=kube-proxy.service
            k8s_node_file_set=([files]="${k8s_node_init_script_name},${docker_install_script_name},${config_docker_flannel_script_name}" [templates]="${kubelet_config_file_name},${kubelet_unit_file_name},${kube_proxy_config_yml},${kube_proxy_unit_file_name}" [tasks]='main.yml' [handlers]='main.yml')
            for key in ${!k8s_node_file_set[*]};do
                handler_file_set[${key}]=${k8s_node_file_set[${key}]}
            done       
            ;;
    esac    

    for dir_name in ${!handler_file_set[*]};do
        local file_dir=${roles_dir}/${dir_name}
        mkdir -p ${file_dir}
        for file_name in `echo ${handler_file_set[${dir_name}]}|sed "s@,@ @g"`;do
            local file_path=${file_dir}/${file_name}
            local function_name=create_${mode_name}_${dir_name}_${file_name%.*}
            #echo function_name:${function_name}
            `$function_name ${file_path}`
        done
    done

}


#创建删除脚本
create_del_script_full(){
    create_del_script etcd
    create_del_script flanneld
    cat >${shell_dir}/roles/del/main.sh <<EOF
#!/bin/bash
source /etc/profile
mode_name=\${1}
shell_dir=\`cd \$(dirname \$0);pwd\`
if [ \$# -ne 1 ];then
    echo "must be 1 args but \$# give it"
    echo "useage: bash \`basename \$0\` etcd|flanneld "
    exit 7
fi
ansible -i \${shell_dir}/../../hosts \${mode_name} --user=${remote_user} -m script -a "\${shell_dir}/del_\${mode_name}.sh"

EOF

}


main(){
    load_var
    load_lib
    write_hosts
    create_csr_full
    create_del_script_full
    init_ansible_roles ca
    init_ansible_roles etcd
    init_ansible_roles flanneld
    init_ansible_roles k8s_master
    init_ansible_roles k8s_node
    
    echo "ansible-playbook  -i ${shell_dir}/../hosts  --user=${remote_user} ${shell_dir}/setup.yml"
    ansible-playbook  -i ${shell_dir}/hosts -l all --user=${remote_user} ${shell_dir}/setup.yml
}

main
end_time=`date +%s`
let use_time=end_time-start_time
echo use_time:${use_time}


