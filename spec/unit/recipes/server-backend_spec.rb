require 'spec_helper'

describe 'chef-reference::server-backend' do
  context 'running the recipe' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |node, server|
        server.create_data_bag('chef_server', topology_data_bag)
        server.create_data_bag('secrets', secrets_data_bag)
        node.automatic['ipaddress'] = '10.10.10.1'
        node.automatic['hostname'] = 'server-backend-fb371ef5'
        node.automatic['fqdn'] = 'server-backend-fb371ef5.chefspec.example.com'
        server.create_node('server-backend', server_backend_node)
      end.converge(described_recipe)
    end

    # We need to ensure that the rendered configuration is what we
    # expect, and since we use a string for ingredient configs, here
    # we are.
    let(:chef_server_rb) do
      <<-EOH
topology 'tier'
api_fqdn 'chef.chefspec.example.com'

# Enable actions for Chef Analytics
dark_launch['actions'] = true

oc_id['applications'] = {
  'analytics' => {
    'redirect_uri' => 'https://analytics.chefspec.example.com'
  },
  'supermarket' => {
    'redirect_uri' => 'https://supermarket.chefspec.example.com/auth/chef_oauth2/callback'
  }
}

# Configuration for server-backend-fb371ef5.chefspec.example.com

server 'server-backend-fb371ef5.chefspec.example.com',
  :ipaddress => '10.10.10.1',
  :bootstrap => true,
  :role      => 'backend'

rabbitmq['vip'] = '10.10.10.1'

backend_vip 'server-backend-fb371ef5.chefspec.example.com',
  :ipaddress => '10.10.10.1'


EOH
    end

    before(:each) do
      allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).and_return(true)
    end

    it 'installs the chef-server ingredient' do
      expect(chef_run).to install_chef_ingredient('chef-server')
        .with(config: chef_server_rb)
    end

    it 'manages the chef-server configuration' do
      expect(chef_run).to render_ingredient_config('chef-server')
    end
  end
end
