require 'spec_helper'

describe 'chef-reference::server-frontend' do
  context 'running the recipe' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |node, server|
        server.create_data_bag('chef_server', topology_data_bag)
        server.create_data_bag('secrets', secrets_data_bag)
        node.automatic['ipaddress'] = '10.10.10.2'
        node.automatic['hostname'] = 'server-frontend-b8821cd9'
        node.automatic['fqdn'] = 'server-frontend-b8821cd9.chefspec.example.com'
        server.create_node('server-backend', server_backend_node)
        server.create_node('server-frontend', server_frontend_node)
      end.converge(described_recipe)
    end

    # We need to ensure that the rendered configuration is what we
    # expect, and since we use a string for ingredient configs, here
    # we are.
    let(:chef_server_rb) do
      <<-EOH
topology "tier"
api_fqdn "chef.chefspec.example.com"

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

# Configuration for server-frontend-b8821cd9.chefspec.example.com

server 'server-frontend-b8821cd9.chefspec.example.com',
  :ipaddress => '10.10.10.2',
  :role      => 'frontend'

rabbitmq['vip'] = '10.10.10.1'

backend_vip 'server-backend-fb371ef5.chefspec.example.com',
  :ipaddress => '10.10.10.1'


EOH
    end

    before(:each) do
      allow_any_instance_of(Chef::Recipe).to receive(:include_recipe)
        .and_return(true)
    end

    it 'installs the chef-server ingredient' do
      expect(chef_run).to install_chef_ingredient('chef-server')
        .with(config: chef_server_rb)
    end

    it 'manages the chef-server configuration' do
      expect(chef_run).to render_ingredient_config('chef-server')
    end

    it 'installs the manage ingredient' do
      expect(chef_run).to install_chef_ingredient('manage')
    end

    it 'installs the reporting ingredient' do
      expect(chef_run).to install_chef_ingredient('reporting')
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
        node.automatic['ipaddress'] = '10.10.10.2'
        node.automatic['hostname'] = 'server-frontend-b8821cd9'
        node.automatic['fqdn'] = 'server-frontend-b8821cd9.chefspec.example.com'
        server.create_node('server-backend', server_backend_node)
        server.create_node('server-frontend', server_frontend_node)
      end.converge(described_recipe)
    end

    before(:each) do
      allow_any_instance_of(Chef::Recipe).to receive(:include_recipe)
        .and_return(true)
    end

    it 'creates the certificate directory' do
      expect(chef_run).to create_directory('/var/opt/opscode/nginx/ca').with(recursive: true)
    end

    it 'creates the pem file' do
      expect(chef_run).to create_file('/var/opt/opscode/nginx/ca/chef.chefspec.example.com.pem').with(
        content: 'pem file'
      )
    end
  end
end
