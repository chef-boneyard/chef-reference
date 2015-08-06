name 'frontend'
run_list 'chef-reference::frontend'
default_source :community

cookbook 'chef-reference', path: '.'
