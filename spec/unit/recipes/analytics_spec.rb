require 'spec_helper'

describe 'chef-reference::analytics' do
  context 'running the recipe' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |node, server|
        server.create_data_bag('chef_server', topology_data_bag)
        server.create_data_bag('secrets', secrets_data_bag)
        node.automatic['ipaddress'] = '10.10.10.3'
        node.automatic['hostname'] = 'analytics-474ba16f'
        node.automatic['fqdn'] = 'analytics-474ba16f.chefspec.example.com'
        server.create_node('server-frontend', server_frontend_node)
      end.converge(described_recipe)
    end

    before(:each) do
      allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).and_return(true)
    end

    it 'creates the opscode directory' do
      expect(chef_run).to create_directory('/etc/opscode')
    end

    it 'creates the opscode-analytics directory' do
      expect(chef_run).to create_directory('/etc/opscode-analytics')
    end

    it 'installs the analytics ingredient and reconfigures it' do
      expect(chef_run).to install_chef_ingredient('analytics')
        .with(config: "topology 'standalone'\nanalytics_fqdn 'analytics.chefspec.example.com'")

      analytics_ingredient = chef_run.chef_ingredient('analytics')
      expect(analytics_ingredient).to notify('chef_ingredient[analytics]').to(:reconfigure).delayed
    end

    it 'manages the analytics configuration' do
      expect(chef_run).to render_ingredient_config('analytics')
    end
  end
end
