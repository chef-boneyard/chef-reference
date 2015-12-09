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

# Attempt to load a wildcard certificate secret. If it fails, continue
# on and rely on the self-signed certs from `reconfigure`. We only
# support wildcard certificates.
begin
  wildcard_cert = data_bag_item('secrets', 'wildcard-ssl')['data']
rescue Net::HTTPServerException
  Chef::Log.debug('Could not load data bag item secrets/wildcard-ssl, will default')
  Chef::Log.debug('to self-signed SSL certificates from `ctl reconfigure`')
  wildcard_cert = false
end

if wildcard_cert
  directory '/var/opt/opscode-analytics/ssl/ca' do
    recursive true
  end

  wildcard_cert.keys.each do |ext|
    next unless wildcard_cert[ext]

    file "/var/opt/opscode-analytics/ssl/ca/#{analytics_fqdn}.#{ext}" do
      content wildcard_cert[ext]
      sensitive true
      notifies :restart, 'omnibus_service[analytics/nginx]'
    end
  end
end

# We define these here instead of including the default recipe because
# analytics doesn't actually need chef-server-core.
directory '/etc/opscode' do
  recursive true
end

directory '/etc/opscode-analytics' do
  recursive true
end

chef_ingredient 'analytics' do
  config "topology 'standalone'\nanalytics_fqdn '#{analytics_fqdn}'"
  notifies :reconfigure, 'chef_ingredient[analytics]'
end

ingredient_config 'analytics' do
  action :render
  notifies :reconfigure, 'chef_ingredient[analytics]'
end

omnibus_service 'analytics/nginx'

include_recipe 'chef-reference::_hostsfile'
