name 'chef-reference'
maintainer 'Chef Software, Inc.'
maintainer_email 'eng-services@chef.io'
license 'apache2'
description 'Reference architecture cookbook for Chef products'
version '0.1.8'

depends 'chef-ingredient'

# TODO: remove after https://github.com/chef/chef-server/pull/465 is released
depends 'line'
