#
# Cookbook Name:: provision
# Recipes:: cluster
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
# This recipe is run on the provisioner node. It creates all the other nodes using chef-provisioning.

include_recipe 'provision::_setup'
include_recipe 'provision::_ssh-keys'

# we're going to stash files locally with machine_file, keep them in a tempdir
directory '/tmp/stash' do
  recursive true
end

machine_batch do
  # need action ready because the default is converge, and the
  # machines are really ready, too.
  action :converge
  machine 'server-backend' do
    machine_options ChefHelpers.get_machine_options(node, 'server-backend')
    attribute %w(chef chef-server role), 'backend'
    attribute %w(chef chef-server bootstrap enable), true
    run_list []
  end

  machine 'server-frontend' do
    machine_options ChefHelpers.get_machine_options(node, 'server-frontend')
    attribute %w(chef chef-server role), 'frontend'
    run_list []
  end

  machine 'analytics' do
    machine_options ChefHelpers.get_machine_options(node, 'analytics')
    attribute %w(chef chef-server role), 'analytics'
    run_list []
  end

  machine 'supermarket' do
    machine_options ChefHelpers.get_machine_options(node, 'supermarket')
    attribute %w(chef chef-server role), 'supermarket'
    run_list []
  end

  machine 'compliance' do
    machine_options ChefHelpers.get_machine_options(node, 'compliance')
    attribute %w(chef chef-server role), 'compliance'
    run_list []
  end
end

machine 'server-backend' do
  chef_config ChefHelpers.use_policyfiles('server-backend')
  action :converge
  converge true
end

%w(actions-source.json webui_priv.pem).each do |analytics_file|
  machine_file "/etc/opscode-analytics/#{analytics_file}" do
    local_path "/tmp/stash/#{analytics_file}"
    machine 'server-backend'
    action :download
  end
end

%w(pivotal.pem webui_pub.pem oc-id-applications/supermarket.json).each do |opscode_file|
  machine_file "/etc/opscode/#{opscode_file}" do
    local_path "/tmp/stash/#{opscode_file.gsub(%r{/}, '-')}"
    machine 'server-backend'
    action :download
  end
end

machine 'server-frontend' do
  chef_config ChefHelpers.use_policyfiles('server-frontend')
  action :converge
  converge true
  files(
    '/etc/opscode/webui_priv.pem' => '/tmp/stash/webui_priv.pem',
    '/etc/opscode/webui_pub.pem' => '/tmp/stash/webui_pub.pem',
    '/etc/opscode/pivotal.pem' => '/tmp/stash/pivotal.pem'
  )
end

machine 'analytics' do
  chef_config ChefHelpers.use_policyfiles('analytics')
  action :converge
  converge true
  files(
    '/etc/opscode-analytics/actions-source.json' => '/tmp/stash/actions-source.json',
    '/etc/opscode-analytics/webui_priv.pem' => '/tmp/stash/webui_priv.pem'
  )
end

machine 'supermarket' do
  chef_config ChefHelpers.use_policyfiles('supermarket')
  action :converge
  converge true
  files(
    '/etc/supermarket/oc-id-applications-supermarket.json' => '/tmp/stash/oc-id-applications-supermarket.json'
  )
end

machine 'compliance' do
  chef_config ChefHelpers.use_policyfiles('compliance')
  action :converge
  converge true
end

# We set solo to false in `_setup`, set it back to true here.
Chef::Config[:solo] = true
