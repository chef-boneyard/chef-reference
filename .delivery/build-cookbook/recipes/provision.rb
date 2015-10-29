#
# Cookbook Name:: build-cookbook
# Recipe:: provision
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

include_recipe 'chef-sugar'

chef_server = DeliverySugar::ChefServer.new
chef_server.send(:load_server_config)

client_pem = data_bag_item(
  'delivery-secrets',
  'chef-reference-provisioner-client'
)['client_pem']

creds = data_bag_item(
  'delivery-secrets',
  'chef-engineering-services-chef-reference'
)

ENV['AWS_ACCESS_KEY_ID']     = creds['access_key_id']
ENV['AWS_SECRET_ACCESS_KEY'] = creds['secret_access_key']

repo_dir = ::File.join(ENV['HOME'], '..', 'repo')
Dir.chdir(repo_dir)

file ::File.join(repo_dir, '.chef', 'config.rb') do
  content <<-EOH
current_dir = File.dirname(__FILE__)
chef_repo_path File.expand_path(File.join(current_dir, '..', 'repo'))
chef_server_url 'https://api.chef.io/organizations/engineering-services'
client_key File.join(current_dir, 'client.pem')
node_name 'chef-reference-provisioner'
EOH
end

file ::File.join(repo_dir, '.chef', 'client.pem') do
  content client_pem
  sensitive true
end

execute 'knife upload /data_bags' do
  cwd repo_dir
end

execute 'rake' do
  cwd repo_dir
  sensitive true
  environment('AWS_ACCESS_KEY_ID'     => creds['access_key_id'],
              'AWS_SECRET_ACCESS_KEY' => creds['secret_access_key'])
end
