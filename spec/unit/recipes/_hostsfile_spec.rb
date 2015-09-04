require 'spec_helper'

describe 'chef-reference::_hostsfile' do
  context 'running the recipe' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |_node, server|
        server.create_data_bag('chef_server', topology_data_bag)
        server.create_node('server-frontend', server_frontend_node)
        server.create_node('supermarket', supermarket_node)
      end.converge(described_recipe)
    end

    it 'adds the supermarket entry to /etc/hosts' do
      expect(chef_run).to edit_append_if_no_line('resolve-supermarket')
        .with(line: '10.10.10.4 supermarket.chefspec.example.com')
    end

    it 'adds the api entry to /etc/hosts' do
      expect(chef_run).to edit_append_if_no_line('resolve-frontend')
        .with(line: '10.10.10.2 chef.chefspec.example.com')
    end
  end
end
