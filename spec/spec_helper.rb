require 'chefspec'

# Requires https://github.com/sethvargo/chefspec/commit/cd57e28fdbd59fc26962c0dd3b1809b8841312f3
require 'chefspec/policyfile'

RSpec.configure do |config|
  config.color = true
  config.formatter = 'doc'
  config.log_level = :error
end

def topology_data_bag
  {
    'topology' => {
      'topology'         => 'tier',
      'api_fqdn'         => 'chef.chefspec.example.com',
      'analytics_fqdn'   => 'analytics.chefspec.example.com',
      'supermarket_fqdn' => 'supermarket.chefspec.example.com'
    }
  }
end

def secrets_data_bag
  {
    'private-chef-secrets-_default'      => { 'data' => {} },
    'opscode-reporting-secrets-_default' => { 'data' => {} }
  }
end

def server_backend_node
  {
    'ipaddress' => '10.10.10.1',
    'fqdn' => 'server-backend-fb371ef5.chefspec.example.com',
    'hostname' => 'server-backend-fb371ef5',
    'chef' => {
      'chef-server' => {
        'role' => 'backend',
        'bootstrap' => { 'enable' => true },
        'configuration' => {
          'vips' => {
            'rabbitmq' => '10.10.10.1'
          }
        }
      }
    }
  }
end

def server_frontend_node
  {
    'ipaddress' => '10.10.10.2',
    'fqdn' => 'server-frontend-b8821cd9.chefspec.example.com',
    'hostname' => 'server-frontend-b8821cd9',
    'chef' => {
      'chef-server' => {
        'role' => 'frontend'
      }
    }
  }
end

def analytics_node
  {
    'ipaddress' => '10.10.10.3',
    'fqdn' => 'analytics-474ba16f.chefspec.example.com',
    'hostname' => 'analytics-474ba16f',
    'chef' => {
      'chef-server' => {
        'role' => 'analytics'
      }
    }
  }
end

def supermarket_node
  {
    'ipaddress' => '10.10.10.4',
    'fqdn' => 'supermarket-7d12789f.chefspec.example.com',
    'hostname' => 'supermarket-7d12789f',
    'chef' => {
      'chef-server' => {
        'role' => 'supermarket'
      }
    }
  }
end
