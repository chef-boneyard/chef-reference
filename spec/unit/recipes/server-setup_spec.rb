require 'spec_helper'

describe 'chef-reference::server-setup' do
  context 'running the recipe' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new.converge(described_recipe)
    end

    it 'creates the opscode directory' do
      expect(chef_run).to create_directory('/etc/opscode')
    end

    it 'creates the analytics directory' do
      expect(chef_run).to create_directory('/etc/opscode-analytics')
    end

    it 'creates the reporting directory' do
      expect(chef_run).to create_directory('/etc/opscode-reporting')
    end
  end
end
