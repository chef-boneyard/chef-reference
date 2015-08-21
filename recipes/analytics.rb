#
# Cookbook Name:: chef-reference
# Recipes:: analytics
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

# TODO: (jtimberman) Maybe we'll use a data bag to store these?
# Maybe we don't need this attribute at all? Or change to 'analytics' and 'frontend' or something.
node.default['chef']['chef-server']['role'] = 'analytics'
topology = data_bag_item('chef_server', 'topology')
analytics_fqdn = topology['analytics_fqdn'] || node['ec2']['public_hostname']

frontend_ip = search( # ~FC003
  'node',
  'chef_chef-server_role:frontend',
  filter_result: { 'ipaddress' => ['ipaddress'] }
).first['ipaddress']

# We define these here instead of including the default recipe because
# analytics doesn't actually need chef-server-core.
directory '/etc/opscode' do
  recursive true
end

directory '/etc/opscode-analytics' do
  recursive true
end

# TODO: (jtimberman) ingredient_config, son, and probably after chef_ingredient?
file '/etc/opscode-analytics/opscode-analytics.rb' do
  content "topology 'standalone'\nanalytics_fqdn '#{analytics_fqdn}'"
  notifies :reconfigure, 'chef_ingredient[analytics]'
end

chef_ingredient 'analytics' do
  notifies :reconfigure, 'chef_ingredient[analytics]'
end

# The analytics system needs to know the IP of the `api_fqdn`
# TODO: (jtimberman) Defer this to the end user to set up their own
# DNS entries
append_if_no_line 'resolve-frontend' do
  path '/etc/hosts'
  line "#{frontend_ip} #{topology['api_fqdn']}"
end
