# Policyfile for Chef Compliance
#
# For more information on the Policyfile feature, visit
# https://github.com/opscode/chef-dk/blob/master/POLICYFILE_README.md

name 'compliance'
run_list 'chef-reference::compliance'
default_source :supermarket

cookbook 'chef-reference', path: File.join(File.dirname(__FILE__), '..')
