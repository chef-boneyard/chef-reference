#
# Cookbook Name:: chef-reference
# Recipe:: _hostsfile
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
# This is an "internal" recipe included by other recipes. It isn't
# recommended that it be used directly.

topology    = data_bag_item('chef_server', 'topology')
frontend    = ChefReferenceHelpers.find_machine_ip
supermarket = ChefReferenceHelpers.find_machine_ip('supermarket')

append_if_no_line 'resolve-supermarket' do
  line "#{supermarket.first['ipaddress']} #{topology['supermarket_fqdn']}"
  path '/etc/hosts'
end

append_if_no_line 'resolve-frontend' do
  line "#{frontend.first['ipaddress']} #{topology['api_fqdn']}"
  path '/etc/hosts'
end
