name 'chef-reference'
run_list 'chef-reference::provisioning-cluster'
default_source :community

cookbook 'chef-reference', path: '.'
