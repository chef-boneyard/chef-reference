node.default['chef']['provisioning'].tap do |provisioning|
  provisioning['key-name'] = 'vagrant'
  provisioning['machine_options'] = {
    'vagrant_provider' => 'vmware_fusion'
  }

  provisioning['driver'] = {
    'gems' => [
      {
        'name' => 'chef-provisioning-vagrant',
        'require' => 'chef/provisioning/vagrant_driver'
      }
    ],
    'with-parameter' => 'vagrant'
  }

  provisioning['server-backend-options'] = {
    vagrant_config: <<-VC
      config.vm.provider "vmware_fusion" do |v|
        v.vmx["memsize"] = "1024"
        v.vmx["numvcpus"] = "2"
      end

      config.vm.box = "opscode-centos-7.1"
      config.vm.network "private_network", ip: "192.168.80.80"
    VC
  }

  provisioning['server-frontend-options'] = {
    vagrant_config: <<-VC
      config.vm.provider "vmware_fusion" do |v|
        v.vmx["memsize"] = "1024"
        v.vmx["numvcpus"] = "2"
      end

      config.vm.box = "opscode-centos-7.1"
      config.vm.network "private_network", ip: "192.168.80.81"
    VC
  }

  provisioning['analytics-options'] = {
    vagrant_config: <<-VC
      config.vm.provider "vmware_fusion" do |v|
        v.vmx["memsize"] = "1024"
        v.vmx["numvcpus"] = "2"
      end

      config.vm.box = "opscode-centos-7.1"
      config.vm.network "private_network", ip: "192.168.80.82"
    VC
  }
end

include_recipe 'provision::cluster'
