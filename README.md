# chef-reference

This is a reference architecture cookbook for building a Chef Server with Chef Analytics and Supermarket. This is an open source cookbook and resides in a public GitHub repository. However it is not a "community" cookbook, as it won't be published to the [public Supermarket](https://supermarket.chef.io). It is narrow in scope for our use cases, but it can be used alongside other cookbooks.

## License Required

This cookbook brings up systems that will run Chef premium features. You need to have a license for running more than 25 nodes. See [plans and pricing](https://www.chef.io/chef/#plans-and-pricing) for further details.

## Maintainers and Support

This cookbook is maintained and supported by Chef's engineering services team. This cookbook runs through our internal Chef Delivery system, and changes must be approved by a member of engineering services.

## Requirements

Local development and use requires ChefDK 0.9.0 or higher.

### Platform:

64 bit Red Hat Enterprise Linux 7.1 or CentOS 7.1

Other platforms may be added in the future according to the [platforms that Chef Server 12 supports](https://docs.chef.io/supported_platforms.html).

### Cookbooks:

* [chef-ingredient](https://github.com/chef-cookbooks/chef-ingredient): manages chef server components/addons and more.

## Attributes

See `attributes/default.rb` for default values for the `chef-reference` cookbook. The `provision` cookbook in this repository has attributes that can be modified for chef-provisioning.

This cookbook is designed primarily to be used with AWS as that is our use case. However, by modifying the various `driver` attributes, other providers may be usable. An example of doing this with [Vagrant](https://vagrantup.com) is provided via the `provision::dev` recipe. The following aspects of AWS configuration can be modified using the `chef provision` command's `--opts` (`-o`) argument. Pass it multiple times to change multiple values.

* `aws_region`: the AWS region, default is `us-west-2`
* `key_name`: the SSH key to use, default is `chef-reference-arch`
* `ssh_user`: the user to login with SSH, default is `ec2-user`
* `image_id`: the AMI, default is the RHEL 7 image
* `instance_type`: instance size to use, default is `m3.medium`
* `subnet_id`: the network id to use, which should automatically place instances in the right VPC
* `security_group_ids`: security group that the instances should be in, specify only one

## Documentation

See the [docs directory](./docs) in this repository for additional documentation:

* [README.md](./docs/README.md): more background and detail
* [getting-started.md](./docs/getting-started.md): how to get started
* [scenario-aws.md](./docs/scenario-aws.md): using AWS for a new cluster, this is the default use case
* [secrets.md](./docs/secrets.md): how to use the required secrets

Chef Server documentation:

* https://docs.chef.io/server/

## Issues

Please report [issues in this repository](https://github.com/chef-cookbooks/chef-reference/issues). Please also understand that this cookbook is intended to be narrow and opinionated in scope, and may not work for all use cases.

## License and Author

- Author: Paul Mooring <paul@chef.io>
- Author: Joshua Timberman <joshua@chef.io>
- Author: Serdar Sutay <serdar@chef.io>
- Copyright (C) 2014-2015 Chef Software, Inc. <legal@chef.io>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
