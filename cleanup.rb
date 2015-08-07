name 'cleanup'
run_list 'chef-reference::provisioning-cleanup'
default_source :community

cookbook 'chef-reference', path: '.'
