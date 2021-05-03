echo "********************************* Prerequisite **************************************"
yum install vim wget -y
con=`nmcli connection show | grep ethernet | awk '{print $1}'`
nmcli connection modify $con connection.autoconnect yes
hostnamectl set-hostname master
vim -c "g/swap/d" -c "wq" /etc/fstab
vim -c "7s/enforcing/permissive/g" -c "wq" /etc/sysconfig/selinux
swapoff -a
setenforce 0
systemctl stop firewalld
systemctl disable firewalld


echo "********************************* Docker Installation **************************************"
wget -O /etc/yum.repos.d/docker.repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce -y
systemctl start docker
systemctl enable docker

echo "********************************* Kubernetes Installation **************************************"
cat > /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
gpgcheck=1
repo_gpgcheck=1
enabled=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg https://packages.cloud.google.com/yum/doc/yum-key.gpg
EOF
yum install kubectl kubelet kubeadm -y
systemctl start kubelet
systemctl enable kubelet
kubeadm init --pod-network-cidr=10.244.0.0/16
mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
wget -O /root/calico.yaml https://docs.projectcalico.org/manifests/calico.yaml
vim -c "%s/docker.io/quay.io/g" -c "wq" /root/calico.yaml
kubectl apply -f /root/calico.yaml


echo "COPY JOIN COMMAND AND PASTE ON WORKER NODES"
