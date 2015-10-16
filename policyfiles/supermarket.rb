# Policyfile for Chef Supermarket
#
# For more information on the Policyfile feature, visit
# https://github.com/opscode/chef-dk/blob/master/POLICYFILE_README.md

name 'supermarket'
run_list 'chef-reference::supermarket'
default_source :community

cookbook 'chef-reference', path: File.join(File.dirname(__FILE__), '..')
cookbook 'chef-ingredient', '= 0.11.3'
