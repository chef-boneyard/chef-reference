node.default['chef']['provisioning'].tap do |provisioning|
  provisioning['key-name'] = 'vagrant'

  provisioning['driver'] = {
    'gems' => [
      {
        'name' => 'chef-provisioning-vagrant',
        'require' => 'chef/provisioning/vagrant_driver'
      }
    ],
    'with-parameter' => 'vagrant'
  }

  provisioning['machine_options'] = {
    vagrant_options: {
      'vm.box' => 'opscode-centos-7.1'
    }
  }
end

include_recipe 'provision::cluster'
