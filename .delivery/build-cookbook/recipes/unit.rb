#
# Cookbook Name:: build-cookbook
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
#

changed_cookbooks.each do |cookbook|
  execute 'chef install' do
    cwd cookbook.path
  end

  execute 'chef update' do
    cwd cookbook.path
  end
end

include_recipe 'delivery-truck::unit'
