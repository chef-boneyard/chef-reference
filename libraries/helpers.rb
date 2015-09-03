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

module ChefReferenceHelpers
  def self.fetch_oc_id_data
    if ::File.exist?('/etc/supermarket/oc-id-applications-supermarket.json')
      data = Chef::JSONCompat.from_json(open('/etc/supermarket/oc-id-applications-supermarket.json').read)
    else
      data = { 'uid' => nil, 'secret' => nil }
    end
    data
  end

  def self.find_machine_ip(role = 'frontend')
    s = Chef::Search::Query.new
    results = s.search(
      :node,
      "chef_chef-server_role:#{role}",
      filter_result: {
        'fqdn' => ['fqdn'],
        'ipaddress' => ['ipaddress'],
        'role' => ['chef', 'chef-server', 'role'],
        'bootstrap' => ['chef', 'chef-server', 'bootstrap', 'enable'],
        'rabbitmq_node_ip' => ['chef', 'chef-server', 'configuration', 'vips', 'rabbitmq']
      }
    )
    # Chef::Search::Query.search returns the answer in the following format
    # [ [ { ... }, { ... }, ... ], starting_index, total_found]
    # so data will be in the first element of the results array
    results.first
  end

  def self.render_server_config_blocks(node)
    # Find all the backend servers
    backends = find_machine_ip('backend')
    backends = backends

    # Write server blocks for all the backend servers
    config = StringIO.new
    backends.each do |backend|
      config.puts "# Configuration for #{backend['fqdn']}"
      config.puts ''
      config.puts "server '#{backend['fqdn']}',"
      config.puts "  :ipaddress => '#{backend['ipaddress']}',"
      config.puts '  :bootstrap => true,' if backend['bootstrap']
      config.puts '  :role      => \'backend\''
      config.puts ''
    end

    # Now add the configuration for the current node. This can be a backend
    # or a frontend node. If the node is backend, we need to check if we already
    # found and added it via search above.
    unless backends.any? { |b| b['fqdn'] == node['fqdn'] }
      config.puts "# Configuration for #{node['fqdn']}"
      config.puts ''
      config.puts "server '#{node['fqdn']}',"
      config.puts "  :ipaddress => '#{node['ipaddress']}',"
      config.puts '  :bootstrap => true,' if node['chef']['chef-server']['bootstrap']['enable']
      config.puts "  :role      => '#{node['chef']['chef-server']['role']}'"
      config.puts ''
    end

    # Now add the rabbitmq['vip'] and backend_vip configuration.
    # TODO(serdar): Currently we have one backend and we are pointing directly
    # to the backend for rabbitmq['vip']. This needs to be reconsidered with HA.
    if node['chef']['chef-server']['role'] == 'backend'
      config.puts "rabbitmq['vip'] = '#{node['ipaddress']}'"
      config.puts 'rabbitmq[\'node_ip_address\'] = \'0.0.0.0\''
      config.puts ''
      config.puts "backend_vip '#{node['fqdn']}',"
      config.puts "  :ipaddress => '#{node['ipaddress']}'"
      config.puts ''
    else # 'frontend'
      backend = backends.first # We only have one backend for now.

      config.puts "rabbitmq['vip'] = '#{backend['rabbitmq_node_ip']}'"
      config.puts ''
      config.puts "backend_vip '#{backend['fqdn']}',"
      config.puts "  :ipaddress => '#{backend['ipaddress']}'"
      config.puts ''
    end

    # return the full config
    config.string
  end
end unless defined?(ChefReferenceHelpers)
