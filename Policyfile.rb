name 'chef-reference'
run_list 'chef-reference::default'
default_source :community

cookbook 'chef-reference', path: '.'
cookbook 'chef-ingredient', '= 0.11.3'
