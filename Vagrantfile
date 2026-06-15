Vagrant.require_version ">= 1.4.3"
VAGRANTFILE_API_VERSION = "2"

BOX = 'generic/rocky9'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # ================================================
  # Variáveis de discos para os nós Ceph
  # ================================================
  ceph_nodes = {
    1 => { name: 'ceph-node1', ip: '192.168.1.101', memory: 1300, disk2: './ceph-node1/ceph-node1_disk2.vdi', disk3: './ceph-node1/ceph-node1_disk3.vdi', disk4: './ceph-node1/ceph-node1_disk4.vdi' },
    2 => { name: 'ceph-node2', ip: '192.168.1.102', memory: 1024, disk2: './ceph-node2/ceph-node2_disk2.vdi', disk3: './ceph-node2/ceph-node2_disk3.vdi', disk4: './ceph-node2/ceph-node2_disk4.vdi' },
    3 => { name: 'ceph-node3', ip: '192.168.1.103', memory: 1024, disk2: './ceph-node3/ceph-node3_disk2.vdi', disk3: './ceph-node3/ceph-node3_disk3.vdi', disk4: './ceph-node3/ceph-node3_disk4.vdi' },
    4 => { name: 'ceph-node4', ip: '192.168.1.104', memory: 750,  disk2: './ceph-node4/ceph-node4_disk2.vdi', disk3: './ceph-node4/ceph-node4_disk3.vdi', disk4: './ceph-node4/ceph-node4_disk4.vdi' },
    5 => { name: 'ceph-node5', ip: '192.168.1.115', memory: 750,  disk2: './ceph-node5/ceph-node5_disk2.vdi', disk3: './ceph-node5/ceph-node5_disk3.vdi', disk4: './ceph-node5/ceph-node5_disk4.vdi' },
    6 => { name: 'ceph-node6', ip: '192.168.1.116', memory: 750,  disk2: './ceph-node6/ceph-node6_disk2.vdi', disk3: './ceph-node6/ceph-node6_disk3.vdi', disk4: './ceph-node6/ceph-node6_disk4.vdi' },
    7 => { name: 'ceph-node7', ip: '192.168.1.117', memory: 750,  disk2: './ceph-node7/ceph-node7_disk2.vdi', disk3: './ceph-node7/ceph-node7_disk3.vdi', disk4: './ceph-node7/ceph-node7_disk4.vdi' },
    8 => { name: 'ceph-node8', ip: '192.168.1.118', memory: 750,  disk2: './ceph-node8/ceph-node8_disk2.vdi', disk3: './ceph-node8/ceph-node8_disk3.vdi', disk4: './ceph-node8/ceph-node8_disk4.vdi' }
  }

  extra_nodes = {
    'openstack-node1' => { ip: '192.168.1.111', memory: 4096, hostname: 'os-node1',                  name: 'os-node1' },
    'client-node1'    => { ip: '192.168.1.110', memory: 512,  hostname: 'client-node1',             name: 'client-node1' },
    'rgw-node1'       => { ip: '192.168.1.106', memory: 512,  hostname: 'rgw-node1.cephcookbook.com', name: 'rgw-node1' },
    'us-east-1'       => { ip: '192.168.1.107', memory: 512,  hostname: 'us-east-1.cephcookbook.com', name: 'us-east-1' },
    'us-west-1'       => { ip: '192.168.1.108', memory: 512,  hostname: 'us-west-1.cephcookbook.com', name: 'us-west-1' },
    'owncloud'        => { ip: '192.168.1.120', memory: 512,  hostname: 'owncloud.cephcookbook.com',  name: 'owncloud' }
  }

  # ================================================
  # Função auxiliar para criação segura dos discos do Ceph
  # ================================================
  def configure_storage_disks(node, disks)
    node.vm.provider "virtualbox" do |v|
      v.customize ["storagectl", :id, "--name", "Ceph-Storage", "--add", "sas", "--controller", "LSILogicSAS", "--portcount", "8"] rescue nil

      disks.each_with_index do |disk, idx|
        next unless disk
        port = idx + 1
        
        dirname = File.dirname(disk)
        FileUtils.mkdir_p(dirname) unless File.directory?(dirname)

        unless File.exist?(disk)
          v.customize ['createhd', '--filename', disk, '--size', 20480, '--format', 'VDI'] rescue nil
        end
        v.customize ['storageattach', :id, '--storagectl', 'Ceph-Storage', '--port', port.to_s, '--device', '0', '--type', 'hdd', '--medium', disk] rescue nil
      end
    end
  end

  # ==================== Ceph Nodes ====================
  ceph_nodes.each do |_, data|
    config.vm.define data[:name] do |node|
      node.vm.box = BOX
      node.vm.hostname = data[:name]

      node.vm.network :private_network, ip: data[:ip], virtualbox__intnet: false

      node.vm.synced_folder ".", "/vagrant", disabled: true
      node.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
      node.vm.provision "shell", path: "post-deploy.sh", run: "always"

      node.vm.provider "virtualbox" do |v|
        v.name = data[:name]
        v.gui = false # Alterado para false para economizar recursos no lab, mude para true se necessário
        v.customize ["modifyvm", :id, "--memory", data[:memory].to_s]
        v.customize ["modifyvm", :id, "--cpus", "2"]
        v.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
      end
    end
  end

  # ==================== Outros Nodes ====================
  extra_nodes.each do |vm_name, data|
    config.vm.define vm_name do |node|
      node.vm.box = BOX
      node.vm.hostname = data[:hostname]
      
      node.vm.network :private_network, ip: data[:ip], virtualbox__intnet: false

      node.vm.synced_folder ".", "/vagrant", disabled: true
      node.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
      node.vm.provision "shell", path: "post-deploy.sh", run: "always"

      node.vm.provider "virtualbox" do |v|
        v.name = data[:name]
        v.gui = false
        v.customize ["modifyvm", :id, "--memory", data[:memory].to_s]
        v.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
      end

      # GATILHO DO ANSIBLE: Executa apenas no último nó ('owncloud') para orquestrar todos os outros
      if vm_name == 'owncloud'
        node.vm.provision "ansible" do |ansible|
          ansible.playbook = "playbook.yml"
          ansible.limit = "all" # Força o Ansible a rodar em todas as máquinas do inventário do Vagrant
          ansible.compatibility_mode = "2.0"
        end
      end

    end
  end
end