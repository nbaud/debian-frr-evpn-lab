# Debian Trixie EVPN/Spine-Leaf Lab (VirtualBox)

Vagrant.configure("2") do |config|

  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
    config.vbguest.no_install  = true
    config.vbguest.no_remote   = true
    config.vbguest.iso_path    = nil
    config.vbguest.warn_only   = true
  end
  # General
  config.vm.box_check_update = false
  config.vm.boot_timeout = 600

  # Topology
  nodes = {
    "leaf01"  => { "intnets" => %w[intnet-1 intnet-2 intnet-1-extra intnet-2-extra], "box" => "boxomatic/debian-13", "ssh_id" => "11" },
    "leaf02"  => { "intnets" => %w[intnet-3 intnet-4 intnet-3-extra intnet-4-extra], "box" => "boxomatic/debian-13", "ssh_id" => "12" },
    "leaf03"  => { "intnets" => %w[intnet-5 intnet-6 intnet-5-extra intnet-6-extra], "box" => "boxomatic/debian-13", "ssh_id" => "13" },
    "spine01" => { "intnets" => %w[intnet-1 intnet-3 intnet-5],                         "box" => "boxomatic/debian-13", "ssh_id" => "21" },
    "spine02" => { "intnets" => %w[intnet-2 intnet-4 intnet-6],                         "box" => "boxomatic/debian-13", "ssh_id" => "22" },
    "vm01"    => { "intnets" => %w[intnet-1-extra intnet-2-extra],                      "box" => "boxomatic/debian-13", "ssh_id" => "31" },
    "vm02"    => { "intnets" => %w[intnet-3-extra intnet-4-extra],                      "box" => "boxomatic/debian-13", "ssh_id" => "32" },
    "vm03"    => { "intnets" => %w[intnet-5-extra intnet-6-extra],                      "box" => "boxomatic/debian-13", "ssh_id" => "33" }
  }

  nodes.each do |node_name, node_data|
    config.vm.define node_name do |node|
      node.vm.box = node_data["box"]
      node.vm.hostname = node_name

      # swp*-like internal links (no IP auto-config—handled by you/Ansible)
      node_data["intnets"].each do |intnet|
        node.vm.network "private_network", virtualbox__intnet: intnet, auto_config: false
      end

      # SSH port forward (unique per node)
      host_port = 2200 + node_data["ssh_id"].to_i
      node.vm.network "forwarded_port", guest: 22, host: host_port, id: "ssh", auto_correct: true

      # VirtualBox params
      node.vm.provider "virtualbox" do |vb|
        vb.name = node_name
        if %w[vm01 vm02 vm03].include?(node_name)
          vb.memory = "512";  vb.cpus = 1
        else
          vb.memory = "2048"; vb.cpus = 2
        end
        # Promisc on all “lab” NICs (adapters start at 2; NAT is 1)
        node_data["intnets"].each_with_index do |_, idx|
          vb.customize ['modifyvm', :id, "--nicpromisc#{idx + 2}", 'allow-vms']
        end
      end

      # No Guest Additions/shared folder: disable default /vagrant
      node.vm.synced_folder ".", "/vagrant", disabled: true

      # Minimal base setup (safe for Debian; no locales fluff unless you want it)
      node.vm.provision "shell", privileged: true, inline: <<-SHELL
        set -e
        # echo "#{node_name} #{node_name}" >> /etc/hosts || true
        # create 'nico' with passwordless sudo + optional pubkey from host (if present)
        # NEW_USER="nico"
        # if ! id "$NEW_USER" &>/dev/null; then
        #   useradd -m -s /bin/bash "$NEW_USER"
        #   mkdir -p /home/$NEW_USER/.ssh
        #   if [ -f /home/vagrant/.ssh/authorized_keys ]; then
        #     cat /home/vagrant/.ssh/authorized_keys >> /home/$NEW_USER/.ssh/authorized_keys
        #   fi
        #   chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh
        #   chmod 700 /home/$NEW_USER/.ssh
        #   chmod 600 /home/$NEW_USER/.ssh/authorized_keys || true
        #   echo "$NEW_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/49-$NEW_USER
        #   chmod 0440 /etc/sudoers.d/49-$NEW_USER
        # fi
        set -e

        # --- hostname resolution (silence "sudo: unable to resolve host") ---
        HOSTNAME="#{node_name}"
        echo "$HOSTNAME" > /etc/hostname
        if ! grep -qE "^[[:space:]]*127\.0\.1\.1[[:space:]]+$HOSTNAME(\b|$)" /etc/hosts; then
          echo "127.0.1.1  $HOSTNAME" >> /etc/hosts
        fi

        # --- user + sudo ---
        NEW_USER="nico"
        if ! id "$NEW_USER" &>/dev/null; then
          useradd -m -s /bin/bash "$NEW_USER"
          echo "$NEW_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/49-$NEW_USER
          chmod 0440 /etc/sudoers.d/49-$NEW_USER
        fi

        # --- ensure .ssh exists ---
        install -d -m 700 -o "$NEW_USER" -g "$NEW_USER" "/home/$NEW_USER/.ssh"

        # --- wait a bit for vagrant key to appear, then copy it ---
        for i in $(seq 1 20); do
          if [ -s /home/vagrant/.ssh/authorized_keys ]; then
            # overwrite to avoid duplicates
            install -m 600 -o "$NEW_USER" -g "$NEW_USER" /home/vagrant/.ssh/authorized_keys "/home/$NEW_USER/.ssh/authorized_keys"
            KEY_OK=1
            break
          fi
          sleep 0.2
        done

        set -e
        apt-get update -y
        DEBIAN_FRONTEND=noninteractive apt-get install -y frr frr-pythontools
        systemctl enable --now frr
      SHELL
    end
  end
end
