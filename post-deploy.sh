#!/bin/bash
value=$( grep -ic "entry" /etc/hosts )
if [ $value -eq 0 ]
then
    # O comando abaixo anexa todo o bloco de texto diretamente no /etc/hosts
    cat << 'EOF' >> /etc/hosts
	
# Verifica se os servidores DNS já existem no /etc/resolv.conf
if ! grep -q "8.8.8.8" /etc/resolv.conf; then
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf
fi

if ! grep -q "8.8.4.4" /etc/resolv.conf; then
    echo "nameserver 8.8.4.4" >> /etc/resolv.conf
fi

# Lista de nós (ajuste conforme necessário)
NODES=("ceph-node1" "ceph-node2" "ceph-node3" "ceph-node4" "ceph-node5" "ceph-node6" "ceph-node7" "ceph-node8")

# 1. Gerar chave SSH no ceph-node1 (se não existir)
if [ ! -f /root/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
	sudo chmod 700 /root/.ssh
fi

# 2. Configuração nos nós remotos
for node in "${NODES[@]}"; do
    echo "Configurando $node..."

    # Distribuir chave pública
    ssh-copy-id -o StrictHostKeyChecking=no root@$node

    # Alterar sshd_config para permitir Root Login e Autenticação por Chave
    ssh root@$node "sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config"
    ssh root@$node "sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config"
    ssh root@$node "sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config"
    
    # Reiniciar serviço SSH no nó remoto
    ssh root@$node "systemctl restart sshd"
done

echo "Configuração SSH concluída com sucesso."



################ ceph-cookbook host entry ############

192.168.1.101 ceph-node1
192.168.1.102 ceph-node2
192.168.1.103 ceph-node3
192.168.1.104 ceph-node4
192.168.1.115 ceph-node5
192.168.1.116 ceph-node6
192.168.1.117 ceph-node7
192.168.1.118 ceph-node8

192.168.1.106 rgw-node1.cephcookbook.com rgw-node1
192.168.1.107 us-east-1.cephcookbook.com us-east-1 
192.168.1.108 us-west-1.cephcookbook.com us-west-1
192.168.1.110 client-node1
192.168.1.111 os-node1.cephcookbook.com os-node1
192.168.1.120 owncloud.cephcookbook.com owncloud

######################################################
EOF
fi