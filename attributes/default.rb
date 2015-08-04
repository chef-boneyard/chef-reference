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
# node['chef']['provisioning']

default['chef']['chef-server'].tap do |server|
  server['topology'] = 'tier'
  server['role'] = 'frontend'
  server['bootstrap']['enable'] = false
end

default['chef']['provisioning'].tap do |provisioning|
  # TODO: (jtimberman) We have this here, and then in the machine_options below,
  # and repetition makes us sad pandas.
  provisioning['key-name'] = 'chef-reference-arch'

  # We default to the aws driver, but by overriding this attribute
  # elsewhere (like a role, or a wrapper cookbook), other drivers should
  # be usable.
  provisioning['driver'] = {
    'gems' => [
      {
        'name' => 'chef-provisioning-aws',
        'require' => 'chef/provisioning/aws_driver'
      }
    ],
    'with-parameter' => 'aws::us-west-2'
  }

  # these use _ instead of - because it maps to the machine_options in
  # chef-provisioning-aws, our default provisioning driver.
  provisioning['machine_options'] = {
    'ssh_username' => 'root',
    'use_private_ip_for_ssh' => false,
    'bootstrap_options' => {
      'key_name' => 'chef-reference-arch',
      'image_id' => 'ami-99bef1a9',
      'instance_type' => 'm3.medium'
    }
  }
end
