name 'bootstrap-backend'
run_list 'chef-reference::bootstrap'
default_source :community

cookbook 'chef-reference', path: '.'
