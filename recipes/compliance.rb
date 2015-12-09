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
  directory '/var/opt/chef-compliance/ssl/ca' do
    recursive true
  end

  wildcard_cert.keys.each do |ext|
    next unless wildcard_cert[ext]

    file "/var/opt/chef-compliance/ssl/ca/#{compliance_fqdn}.#{ext}" do
      content wildcard_cert[ext]
      sensitive true
      notifies :restart, 'omnibus_service[compliance/nginx]'
    end
  end
end

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

omnibus_service 'compliance/nginx'
