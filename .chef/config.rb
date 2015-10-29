# See https://docs.chef.io/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
chef_repo_path File.expand_path(File.join(current_dir, '..', 'repo'))

chef_server_url 'http://localhost:7788'
# Use a dummy client name and pem file in order to talk to chef-zero locally.
node_name 'dummy'
client_key File.join(current_dir, 'dummy.pem')

versioned_cookbooks true
policy_document_native_api false
