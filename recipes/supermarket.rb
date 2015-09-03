#
# Cookbook Name:: chef-reference
# Recipe:: supermarket
#
# Copyright 2015 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
node.default['chef']['chef-server']['role'] = 'supermarket'
topology = data_bag_item('chef_server', 'topology')
oc_id_data = ChefReferenceHelpers.fetch_oc_id_data

directory '/etc/supermarket' do
  recursive true
end

chef_ingredient 'supermarket' do
  # We're using self signed certificates so don't verify SSL
  config <<-CONFIG
{
  "fqdn": "#{topology['supermarket_fqdn']}",
  "host": "#{topology['supermarket_fqdn']}",
  "chef_server_url": "https://#{topology['api_fqdn']}",
  "chef_oauth2_app_id": "#{oc_id_data['uid']}",
  "chef_oauth2_secret": "#{oc_id_data['secret']}",
  "chef_oauth2_verify_ssl": false
}
CONFIG
end

ingredient_config 'supermarket' do
  action :render
  notifies :reconfigure, 'chef_ingredient[supermarket]'
end

include_recipe 'chef-reference::_hostsfile'
