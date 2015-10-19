# Policyfile for Chef Analytics.
#
# For more information on the Policyfile feature, visit
# https://github.com/opscode/chef-dk/blob/master/POLICYFILE_README.md

name 'analytics'
run_list 'chef-reference::analytics'
default_source :community

cookbook 'chef-reference', path: File.join(File.dirname(__FILE__), '..')
