# Use policyfiles for installing test dependencies
name 'test-chef-reference'
default_source :community

# run_list: chef-client will run these recipes in the order specified.
run_list(
  'test-chef-reference',
  'chef-reference'
)

cookbook cookbook_name, path: '.'
cookbook 'test-chef-reference', path: './test/fixtures/cookbooks/test-chef-reference'
