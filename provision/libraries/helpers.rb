#
# Cookbook Name:: chef-reference
# Libraries:: helpers
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

module ChefHelpers
  # returns an array of all the "secrets" files that are automatically
  # generated on an initial `chef-server-ctl reconfigure` run.
  def self.secret_files
    %w(pivotal.cert  pivotal.pem  webui_priv.pem  webui_pub.pem  worker-private.pem  worker-public.pem)
  end

  def self.symbolize_keys_deep!(h)
    Chef::Log.debug("#{h.inspect} is a hash with string keys, make them symbols")
    h.keys.each do |k|
      ks    = k.to_sym
      h[ks] = h.delete k
      symbolize_keys_deep! h[ks] if h[ks].is_a? Hash
    end
    h
  end

  def self.get_machine_options(node, machine_name)
    global_options = node['chef']['provisioning']['machine_options'].to_hash
    individual_options = node['chef']['provisioning']["#{machine_name}-options"].to_hash
    symbolize_keys_deep! global_options.merge(individual_options)
  end

  def self.server_supports_policies?
    require 'chef/server_api'
    api = Chef::ServerAPI.new
    begin
      api.get('/policies')
      true
    rescue Net::HTTPServerException
      false
    end
  end

  def self.use_policyfiles(role)
    # TODO: support policy_group setting in some way. optimally from
    # the context (and pass that in from the recipe)
    if server_supports_policies?
      chef_config = <<-CONF.gsub(/^\s+/, '')
        use_policyfile true
        policy_document_native_api true
        policy_group "reference"
        policy_name "#{role}"
      CONF
    else
      chef_config = <<-CONF.gsub(/^\s+/, '')
        use_policyfile true
        policy_document_native_api false
        deployment_group "#{role}-reference"
      CONF
    end
    chef_config
  end
end
