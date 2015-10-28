#
# Cookbook Name:: provision
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

context_opts = ChefDK::ProvisioningData.context.opts

default['chef']['provisioning'].tap do |provisioning|
  # TODO: (jtimberman) We have this here, and then in the machine_options below,
  # and repetition makes us sad pandas.
  provisioning['key-name'] = context_opts.key_name || context_opts.keyname || 'chef-reference-arch'

  # we default to the aws driver, but by overriding this attribute
  # elsewhere (like a role, or a wrapper cookbook), other drivers should
  # be usable.
  provisioning['driver'] = {
    'gems' => [
      {
        'name' => 'chef-provisioning-aws',
        'require' => 'chef/provisioning/aws_driver'
      }
    ],
    'with-parameter' => "aws::#{context_opts.region || 'us-west-2'}"
  }

  # these use _ instead of - because it maps to the machine_options in
  # chef-provisioning-aws, our default provisioning driver.
  provisioning['machine_options'] = {
    'ssh_username' => 'ec2-user',
    'use_private_ip_for_ssh' => false,
    'bootstrap_options' => {
      'key_name' => context_opts.key_name || context_opts.keyname || 'chef-reference-arch',
      # https://aws.amazon.com/marketplace/pp/B00VIMU19E, us-west-2 region
      'image_id' => context_opts.image_id || context_opts.ami || 'ami-4dbf9e7d',
      'instance_type' => context_opts.instance_type || 'm3.medium'
    }
  }

  # these can configure per machine options to be used during provisioning.
  # default is an empty hash. You can override this with your Policyfile
  # or wrapper cookbook. e.g.:
  # node.default['chef']['provisioning']['server-backend-options'] = {
  #   'bootstrap_options' => {
  #     'instance_type' => 'c3.xl'
  #   }
  # }
  ['server-backend', 'server-frontend', 'analytics', 'supermarket'].each do |machine|
    provisioning["#{machine}-options"] = {}
  end
end
