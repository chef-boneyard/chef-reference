require 'spec_helper'

describe 'chef-reference::supermarket' do
  context 'running the recipe' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |node, server|
        server.create_data_bag('chef_server', topology_data_bag)
        server.create_data_bag('secrets', secrets_data_bag)
        node.automatic['ipaddress'] = '10.10.10.4'
        node.automatic['hostname'] = 'supermarket-7d12789f'
        node.automatic['fqdn'] = 'supermarket-7d12789f.chefspec.example.com'
        server.create_node('server-frontend', server_frontend_node)
      end.converge(described_recipe)
    end

    let(:oc_id_data) do
      {
        'name' => 'supermarket',
        'uid' => '123456',
        'secret' => '654321',
        'redirect_uri' => 'https://supermarket.chefspec.example.com'
      }
    end

    let(:supermarket_json) do
      <<-EOH
{
  "fqdn": "supermarket.chefspec.example.com",
  "host": "supermarket.chefspec.example.com",
  "chef_server_url": "https://chef.chefspec.example.com",
  "chef_oauth2_app_id": "123456",
  "chef_oauth2_secret": "654321",
  "chef_oauth2_verify_ssl": false
}
EOH
    end

    before(:each) do
      allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).and_return(true)
    end

    it 'creates the supermarket directory' do
      expect(chef_run).to create_directory('/etc/supermarket')
    end

    it 'installs the supermarket ingredient' do
      # we do this here instead of in `before` because otherwise we'll
      # get an uninitialized constant exception
      allow(ChefReferenceHelpers).to receive(:fetch_oc_id_data).and_return(oc_id_data)
      expect(chef_run).to install_chef_ingredient('supermarket')
        .with(config: supermarket_json)
    end

    it 'manages the supermarket configuration' do
      expect(chef_run).to render_ingredient_config('supermarket')
    end
  end
end
