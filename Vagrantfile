# ------------------------
Vagrant.require_version ">= 2.0.0"
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  # config.vm.box_version = "1.0.282"
  # ------------------------
  config.vm.box_check_update = false
  config.vm.synced_folder "artefacts/", "/artefacts"
  config.vm.synced_folder "data/", "/data", :mount_options => ["ro"]
  # ------------------------
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "4096"
    # vb.cpus = 4
    vb.cpus = `nproc`.to_i
  end
  # ------------------------
  config.vm.provision "shell", inline: <<-SHELL
    echo "building image ..."
    bash /artefacts/runme.sh
  SHELL
end

