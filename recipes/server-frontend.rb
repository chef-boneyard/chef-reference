#
# Cookbook Name:: chef-reference
# Recipes:: server-frontend
#
# Copyright (C) 2015, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'chef-reference::server-setup'

node.default['chef']['chef-server']['role'] = 'frontend'

# TODO: remove after https://github.com/chef/chef-server/pull/465 is released
# IPV6 hack - avoid having oc_id listen on ipv6 address by removing the entry
# for localhost in /etc/hosts.
delete_lines 'Remove IPV6 localhost' do
  path '/etc/hosts'
  pattern '^::1.*'
end
# End IPV6 hack

# TODO: (jtimberman) chef_vault_item. We sort this so we don't
# get regenerated content in the private-chef-secrets.json later.
chef_secrets      = Hash[data_bag_item('secrets', "private-chef-secrets-#{node.chef_environment}")['data'].sort]
reporting_secrets = Hash[data_bag_item('secrets', "opscode-reporting-secrets-#{node.chef_environment}")['data'].sort]

file '/etc/opscode/private-chef-secrets.json' do
  content JSON.pretty_generate(chef_secrets)
  notifies :reconfigure, 'chef_ingredient[chef-server]'
  sensitive true
end

file '/etc/opscode-reporting/opscode-reporting-secrets.json' do
  content JSON.pretty_generate(reporting_secrets)
  notifies :reconfigure, 'chef_ingredient[reporting]'
  sensitive true
end

# It's easier to deal with a hash rather than a data bag item, since
# we're not going to need any of the methods, we just need raw data.
chef_server_config = data_bag_item('chef_server', 'topology').to_hash
chef_server_config.delete('id')
node.default['chef']['chef-server']['configuration'].merge!(chef_server_config)

chef_ingredient 'chef-server' do
  action :install
  config <<-CONFIG
topology "#{chef_server_config['topology']}"
api_fqdn "#{chef_server_config['api_fqdn']}"

# Enable actions for Chef Analytics
dark_launch['actions'] = true

oc_id['applications'] = {
  'analytics' => {
    'redirect_uri' => 'https://#{chef_server_config['analytics_fqdn']}'
  },
  'supermarket' => {
    'redirect_uri' => 'https://#{chef_server_config['supermarket_fqdn']}/auth/chef_oauth2/callback'
  }
}

#{ChefReferenceHelpers.render_server_config_blocks(node)}
CONFIG
end

ingredient_config 'chef-server' do
  action :render
  notifies :reconfigure, 'chef_ingredient[chef-server]'
end

chef_ingredient 'manage' do
  notifies :reconfigure, 'chef_ingredient[manage]'
end

chef_ingredient 'reporting' do
  notifies :reconfigure, 'chef_ingredient[reporting]'
end

include_recipe 'chef-reference::_hostsfile'
