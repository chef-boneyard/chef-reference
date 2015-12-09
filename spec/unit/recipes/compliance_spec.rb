require 'spec_helper'

describe 'chef-reference::compliance' do
  context 'running the recipe' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |node, server|
        server.create_data_bag('chef_server', topology_data_bag)
        server.create_data_bag('secrets', secrets_data_bag)
        node.automatic['ipaddress'] = '10.10.10.5'
        node.automatic['hostname'] = 'compliance-3d50120d'
        node.automatic['fqdn'] = 'compliance-3d50120d.chefspec.example.com'
      end.converge(described_recipe)
    end

    it 'creates the chef-compliance directory' do
      expect(chef_run).to create_directory('/etc/chef-compliance')
    end

    it 'installs the compliance ingredient and reconfigures it' do
      expect(chef_run).to install_chef_ingredient('compliance')
        .with(config: "fqdn 'compliance.chefspec.example.com'")
      expect(chef_run).to reconfigure_chef_ingredient('compliance')
    end

    it 'manages the compliance configuration' do
      expect(chef_run).to render_ingredient_config('compliance')
    end
  end

  context 'running the recipe with wildcard cert data' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |node, server|
        server.create_data_bag('chef_server', topology_data_bag)
        server.create_data_bag('secrets', secrets_data_bag.merge(
                                            'wildcard-ssl' => {
                                              'data' => {
                                                'pem' => 'pem file'
                                              }
                                            }
        ))
        node.automatic['ipaddress'] = '10.10.10.5'
        node.automatic['hostname'] = 'compliance-3d50120d'
        node.automatic['fqdn'] = 'compliance-3d50120d.chefspec.example.com'
      end.converge(described_recipe)
    end

    before(:each) do
      allow_any_instance_of(Chef::Recipe).to receive(:include_recipe)
        .and_return(true)
    end

    it 'creates the certificate directory' do
      expect(chef_run).to create_directory('/var/opt/chef-compliance/ssl/ca').with(recursive: true)
    end

    it 'creates the pem file' do
      expect(chef_run).to create_file('/var/opt/chef-compliance/ssl/ca/compliance.chefspec.example.com.pem').with(
        content: 'pem file'
      )
    end
  end
end
