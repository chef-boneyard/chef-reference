#
# Cookbook Name:: build-cookbook
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
#
# we'd use delivery-truck, but we need to bundle install so we can
# have chefspec that supports policyfiles.
changed_cookbooks.each do |cookbook|
  execute "bundle install #{cookbook.name}" do
    cwd cookbook.path
    command 'bundle install --path=vendor --binstubs'
    only_if { ::File.exist?(File.join(cookbook.path, 'Gemfile'))  }
  end

  execute "unit_rspec_#{cookbook.name}" do
    cwd cookbook.path
    command 'bundle exec rspec --format documentation --color'
    only_if { has_spec_tests?(cookbook.path) }
  end
end
