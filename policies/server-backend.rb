# Policyfile for Chef Server backend.
#
# For more information on the Policyfile feature, visit
# https://github.com/opscode/chef-dk/blob/master/POLICYFILE_README.md

name 'server-backend'
run_list 'chef-reference::server-backend'
default_source :community

cookbook 'chef-reference', path: File.join(File.dirname(__FILE__), '..')
