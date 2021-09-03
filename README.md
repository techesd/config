# config

Scripts para preparar e rodar os LABS no AWS Academy.
---
O pacote de cloud-init configura aspectos específicos de uma nova instância.

1) Preparação:
> nano ~/.aws/credentials <br>
> inserir credenciais <br>
> executar o comando em sua maquina local: ssh-keygen -y -f ./labsuser.pem > public_key.pem <br>

> git clone  <br>
> pegar o conteudo do arquivo e inserir no public_key.pem.  <br>
---
2) Execução
> cd ec2-instance  <br>
> terraform init  <br>
> terraform plan  <br>
> terraform apply  <br>
---
3) Conectar 
> ssh -i "labsuser.pem" ubuntu@ip <br>
> cat /var/log/cloud-init-output.log > script_init.log <br>
<br><br>
O arquivo de log de saída de cloud-init (/var/log/cloud-init-output.log) captura a saída do console para facilitar a depuração de seus scripts após uma execução se a instância não se comportar da maneira desejada.
<br><br>
Quando um script de dados do usuário é processado, ele é copiado para /var/lib/cloud/instances/instance-id/ e executado a partir desse diretório.
<br><br>
---
4) Comandos linux para verificar a utilização de componentes (ex: memória, cpu e disco) 

Habilitar ccat
> alias cat='/usr/local/bin/ccat --bg=dark'

Utilização de cpu
> htop

Utilização de memória
> free -mh

Espaço em disco
> df -h

Pastas que ocupam mais espaços na raiz /
> sudo du -cha --max-depth=1 / | grep -E "M|G"
---
Fontes:

> https://github.com/akskap/esk8s
<br>> https://github.com/terraform-providers/terraform-provider-aws/tree/master/examples/two-tier
<br>> https://github.com/heap/terraform-ebs-attachmentizer
<br>> https://github.com/terraform-aws-modules

Pesquisa e substituição de textos em arquivos:
> grep -Ril "config-ubuntu" .

> grep -rli 'config-ubuntu' * | xargs -i@ sed -i 's/config-ubuntu/config/g' @  

Ansible
> ansible --inventory-file ~/environment/hosts -u ec2-user --key-file ~/environment/labsuser.pem all -m ping 

> ansible-playbook ansible.yml --inventory-file ~/environment/hosts -u ec2-user --key-file ~/environment/labsuser.pem
