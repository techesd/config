# conectar no master e configurar

export DIRETORIO='/home/ec2-user'
# ~/environment/ip | awk -Fv '{ if ( !($1 ~  "None") ) { print } }'

MASTER=$(terraform output -json ip_externo | jq .[] | jq .[0] | sed 's/"//g')
QTD_NODES=$(terraform output -json ip_externo | jq '.[] | length')
WORKER_NODES=$(expr $QTD_NODES - 1)

#MASTER=$(~/environment/ip | awk -Fv '{ if ( !($1 ~  "None") && (/vm_0/) ) { print $1} }')
#NODE1=$(~/environment/ip | awk -Fv '{ if ( !($1 ~  "None") && (/vm_1/) ) { print $1} }')
#NODE2=$(~/environment/ip | awk -Fv '{ if ( !($1 ~  "None") && (/vm_2/) ) { print $1} }')
#NODE3=$(~/environment/ip | awk -Fv '{ if ( !($1 ~  "None") && (/vm_3/) ) { print $1} }')
echo "IPs configurados :"
echo "MASTER = $MASTER"
#echo "NODE1 = $NODE1"
#echo "NODE2 = $NODE2"
#echo "NODE3 = $NODE3"
#MASTER=$(~/environment/ip | awk -Fv '/vm_0/{print $1}')
#NODE1=$(~/environment/ip | awk -Fv '/vm_1/{print $1}')
#NODE2=$(~/environment/ip | awk -Fv '/vm_2/{print $1}')
#NODE3=$(~/environment/ip | awk -Fv '/vm_3/{print $1}')

# reset arquivos vazios dos scripts:
> master.sh
#> worker1.sh
#> worker2.sh
#> worker3.sh

# CONFIGURANDO O MASTER utilizando o KUBEADM INIT:
#echo "sudo hostnamectl set-hostname master" >> master.sh
echo "Aguardando instalação do KUBEADM."
#ssh -oStrictHostKeyChecking=no -i ~/environment/labsuser.pem ec2-user@$MASTER "sudo hostnamectl set-hostname master"
#ssh -oStrictHostKeyChecking=no -i ~/environment/labsuser.pem ec2-user@$MASTER "while [ \$(dpkg -l | grep kubeadm | wc -l) != '1' ]; do { printf .; sleep 1; } done"
#echo "while [ \$(dpkg -l | grep kubeadm | wc -l) != '1' ]; do { printf .; sleep 1; } done" >> master.sh
echo "kubeadm version" >> master.sh
echo "sudo kubeadm config images pull" >> master.sh
echo "sudo kubeadm init --control-plane-endpoint \$(curl checkip.amazonaws.com):6443" >> master.sh
### INICIANDO O MASTER via SSH
ssh -oStrictHostKeyChecking=no -i ~/environment/labsuser.pem ec2-user@$MASTER 'bash -s' < master.sh

#	Configurar o cliente kubectl:
echo "mkdir -p $DIRETORIO/.kube" > master.sh
echo "sudo cp -i /etc/kubernetes/admin.conf $DIRETORIO/.kube/config" >> master.sh
echo "sudo chown $(id -u):$(id -g) $DIRETORIO/.kube/config" >> master.sh
#echo "source <(kubectl completion bash)" >> master.sh

# validar
#cat master.sh

### CONFIGURANDO O MASTER via SSH
ssh -oStrictHostKeyChecking=no -i ~/environment/labsuser.pem ec2-user@$MASTER 'bash -s' < master.sh
# Get Token
TOKEN=$(ssh -oStrictHostKeyChecking=no -i ~/environment/labsuser.pem ec2-user@$MASTER 'sudo kubeadm token create --print-join-command')
printf "\n\n"
echo $TOKEN
printf "\n\n"
echo "   TOKEN ACIMA : KUBEADM JOIN"
printf "\n\n"
echo "Master do Cluster foi inicializado. Agora vamos configurar a rede do cluster."
# Configurar a rede do cluster:
ssh -oStrictHostKeyChecking=no -i ~/environment/labsuser.pem ec2-user@$MASTER 'bash -s' < k8s_config_network_weave.sh

### CONFIGURANDO OS NODES utilizando o KUBEADM JOIN:

# Exemplo:
# kubeadm join 10.0.1.169:6443 --token fdwf9o.om0jvrom7uv3eeg4 \
#    --discovery-token-ca-cert-hash sha256:46abcfc7e371878b78f1071a7e396a3b1f1e851cbec76e65f0030d3f73411fd1
printf "\n\n"
echo "CONFIGURANDO OS NODES utilizando o KUBEADM JOIN:"
#echo "Copie e cole 2 linhas com KUBEADM JOIN exibido acima: (digite ENTER PARA CONCLUIR)"
#echo "Exemplo das 2 linhas a serem copiadas:"
#echo " kubeadm join 10.0.1.169:6443 --token fdwf9o.om0jvrom7uv3eeg4 "
#echo "    --discovery-token-ca-cert-hash sha256:46abcfc7e371878b78f1071a7e396a3b1f1e851cbec76e65f0030d3f73411fd1"
#read TOKEN
#read ENTER

#echo "sudo hostnamectl set-hostname worker1" >> worker1.sh
#echo "sudo hostnamectl set-hostname worker2" >> worker2.sh
#echo "sudo hostnamectl set-hostname worker3" >> worker3.sh

echo "sudo $TOKEN" >> workers.sh
#echo "sudo $TOKEN" >> worker1.sh
#echo "sudo $TOKEN" >> worker2.sh
#echo "sudo $TOKEN" >> worker3.sh

for N in $(seq 1 $WORKER_NODES); do
    printf "\n\n"
    NODE=$(terraform output -json ip_externo | jq .[] | jq .[$N] | sed 's/"//g')
    echo "   CONFIGURANDO NODE $N ($NODE): KUBEADM JOIN"
    ssh -oStrictHostKeyChecking=no -i ~/environment/labsuser.pem ec2-user@$NODE 'bash -s' < workers.sh
done

# validar
#cat worker1.sh
#printf "\n\n"
#echo "   CONFIGURANDO NODE 1: KUBEADM JOIN"
#printf "\n\n"
#ssh -oStrictHostKeyChecking=no -i ~/environment/labsuser.pem ec2-user@$NODE1 'bash -s' < worker1.sh
#printf "\n\n"
#echo "   CONFIGURANDO NODE 2: KUBEADM JOIN"
#printf "\n\n"
#ssh -oStrictHostKeyChecking=no -i ~/environment/labsuser.pem ec2-user@$NODE2 'bash -s' < worker2.sh
#printf "\n\n"
#echo "   CONFIGURANDO NODE 3: KUBEADM JOIN"
#printf "\n\n"
#ssh -oStrictHostKeyChecking=no -i ~/environment/labsuser.pem ec2-user@$NODE3 'bash -s' < worker3.sh
#printf "\n\n"
echo "   VERIFICANDO NODES NO MASTER :"
printf "\n\n"
ssh -oStrictHostKeyChecking=no -i ~/environment/labsuser.pem ec2-user@$MASTER 'kubectl get nodes'

### CONFIGURANDO OS VOLUMES 
#sh k8s_criar_volume_portworx.sh

printf "\n\n"
echo "   CONFIGURAÇÕES REALIZADAS. FIM."
ssh -oStrictHostKeyChecking=no -i ~/environment/labsuser.pem ec2-user@$MASTER 'kubectl get nodes'
printf "\n\n"
