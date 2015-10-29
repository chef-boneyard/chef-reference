#
# Cookbook Name:: chef-reference
# Recipe:: compliance
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

node.default['chef']['chef-server']['role'] = 'compliance'
topology = data_bag_item('chef_server', 'topology')
compliance_fqdn = topology['compliance_fqdn'] || node['ec2']['public_hostname']

directory '/etc/chef-compliance' do
  recursive true
end

chef_ingredient 'compliance' do
  config "fqdn '#{compliance_fqdn}'"
  action [:install, :reconfigure]
end

ingredient_config 'compliance' do
  action :render
  notifies :reconfigure, 'chef_ingredient[compliance]'
end
