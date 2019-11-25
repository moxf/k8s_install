### k8s集群二进制包一键安装脚本
#### 功能说明
通过shell脚本读取配置文件构建ansible-playbook，自动部署一套生产级标准高可用k8s基础集群

#### 测试环境信息
|选项|描述|
|----|----|
|操作系统|centos 7.5.1804|
|etcd二进制包|etcd-v3.2.28-linux-amd64.tar.gz|
|flanneld二进制包|flannel-v0.11.0-linux-amd64.tar.gz|
|k8s二进制包|kubernetes-server-linux-1.14.9-amd64.tar.gz|
|docker版本|docker-ce-19.03.4-3.el7|
|ca主机|172.17.0.129|
|etcd集群主机|172.17.0.129、172.17.0.130、172.17.0.131|
|k8s_master集群主机|172.17.0.129、172.17.0.130、172.17.0.131|
|k8s_node主机|172.17.0.132、172.17.0.134|

#### 集群主要配置策略
- 基础部署信息
1. 集群软件包皆部署于/opt
2. 日志皆配置于/log
3. 数据存于/data
4. 证书文件目录/opt/应用部署目录/cert
5. 配置文件目录/opt/应用部署目录/config

- kube-apiserver
1. 3节点高可用
2. 关闭非安全端口 8080 和匿名访问
3. 在安全端口 6443 接收 https 请求
4. 严格的认证和授权策略 (x509、token、RBAC)
5. 开启 bootstrap token 认证，支持 kubelet TLS bootstrapping
6. 使用 https 访问 kubelet、etcd，加密通信

- kube-controller-manager
1. 3 节点高可用
2. 关闭非安全端口，在安全端口 10252 接收 https 请求
3. 使用 kubeconfig 访问 apiserver 的安全端口
4. 自动 approve kubelet 证书签名请求 (CSR)，证书过期后自动轮转
5. 各 controller 使用自己的 ServiceAccount 访问 apiserver

- kube-scheduler
1. 3 节点高可用
2. 使用 kubeconfig 访问 apiserver 的安全端口

- kubelet
1. 使用 kubeadm 动态创建 bootstrap token，而不是在 apiserver 中静态配置
2. 使用 TLS bootstrap 机制自动生成 client 和 server 证书，过期后自动轮转
3. 在 KubeletConfiguration 类型的 JSON 文件配置主要参数
4. 关闭只读端口，在安全端口 10250 接收 https 请求，对请求进行认证和授权，拒绝匿名访问和非授权访问
5. 使用 kubeconfig 访问 apiserver 的安全端口

- kube-proxy
1. 使用 kubeconfig 访问 apiserver 的安全端口
2. 在 KubeProxyConfiguration 类型的 JSON 文件配置主要参数
3. 使用 ipvs 代理模式


#### 使用说明
- 在控制机器上安装ansible并能让控制机以root用户免密登录上所有机器
```
yum -y install ansible
```

- 下载部署脚本
```
git clone https://github.com/moxf/k8s_install.git
```

- 编辑配置文件
```
cd k8s_install
vim config.ini 

#修改软件包信息
etcd_package_name=xxx
flanneld_package_name=xxx
k8s_package_name=xxx

#修改集群主机信息
etcd_host_set=xxx
k8s_master_host_set=xxx
k8s_node_host_set=xxx

#修改docker版本信息
docker_version=xxx

#修改apiserver访问地址
apiserver_host=xxx
```

- 将etcd、flanneld、kubernetes-server二进制安装包拷贝到本工程目录下的src目录
```
cp  etcdxxx src/
cp  flanneldxxx src/
cp  kubernetesxxx src/
```

- 安装
```
bash setup.sh
```

- 查看结果
```
#登录到任何一台master机器
kubectl get nodes
```
