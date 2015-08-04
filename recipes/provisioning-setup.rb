#
# Cookbook Name:: chef-reference
# Recipes:: provisioning-setup
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

node['chef']['provisioning']['driver']['gems'].each do |g|
  chef_gem g['name'] do # ~FC009
    # Foodcritic needs to be updated to know about `compile_time`:
    # https://github.com/acrmp/foodcritic/tree/master/chef_dsl_metadata
    compile_time true if Chef::Resource::ChefGem.method_defined?(:compile_time)
  end

  require g['require'] if g.key?('require')
end

# We're not doing anything special with regard to authentication
# options here. WRT AWS, this assumes a default of ~/.aws/config.
provisioner_machine_opts = node['chef']['provisioning']['machine_options'].to_hash
ChefHelpers.symbolize_keys_deep!(provisioner_machine_opts)

with_driver(node['chef']['provisioning']['driver']['with-parameter'])
with_machine_options(provisioner_machine_opts)
