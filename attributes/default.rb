#
# Cookbook Name:: chef-reference
# Attributes:: default
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

# Each of the attribute namespaces are based on the product names from
# https://github.com/chef-cookbooks/chef-ingredient/blob/master/PRODUCT_MATRIX.md
#
# We use `default` precedence to make it easy for consumers to override these.
#
# node['chef']['chef-server']
# node['chef']['analytics']
# node['chef']['delivery']
# node['chef']['reporting']
# node['chef']['manage']

default['chef']['chef-server'].tap do |server|
  server['topology'] = 'tier'
  server['role'] = 'frontend'
  server['bootstrap']['enable'] = false
end

default['yum-chef']['repositoryid'] = 'chef-current'
default['yum-chef']['baseurl']      = 'https://packagecloud.io/chef/current/el/7/$basearch'

default['apt-chef']['repo_name']    = 'chef-current'
default['apt-chef']['uri']          = 'https://packagecloud.io/chef/current/ubuntu/'
