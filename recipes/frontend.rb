#
# Cookbook Name:: chef-reference
# Recipes:: frontend
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
include_recipe 'chef-reference'

node.default['chef']['chef-server']['role'] = 'frontend'

# TODO: (jtimberman) chef_vault_item. We sort this so we don't
# get regenerated content in the private-chef-secrets.json later.
chef_secrets      = Hash[data_bag_item('secrets', "private-chef-secrets-#{node.chef_environment}")['data'].sort]
reporting_secrets = Hash[data_bag_item('secrets', "opscode-reporting-secrets-#{node.chef_environment}")['data'].sort]

# It's easier to deal with a hash rather than a data bag item, since
# we're not going to need any of the methods, we just need raw data.
chef_server_config = data_bag_item('chef_server', 'topology').to_hash
chef_server_config.delete('id')

chef_servers << {
  fqdn: node['fqdn'],
  ipaddress: node['ipaddress'],
  bootstrap: false,
  role: 'frontend'
}

node.default['chef']['chef-server'].merge!(chef_server_config)

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

template '/etc/opscode/chef-server.rb' do
  source 'chef-server.rb.erb'
  variables chef_server_config: node['chef']['chef-server'], chef_servers: chef_servers
  notifies :reconfigure, 'chef_ingredient[chef-server]'
end

chef_ingredient 'opscode-manage' do
  notifies :reconfigure, 'chef_ingredient[manage]'
end

chef_ingredient 'opscode-reporting' do
  notifies :reconfigure, 'chef_ingredient[reporting]'
end
