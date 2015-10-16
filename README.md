# chef-reference

Reference architecture cookbook for building a Chef Server with Chef Analytics, Supermarket. This is an open source cookbook and resides in a public GitHub repository. However it is not a "community" cookbook, as it won't be published to the [public Supermarket](https://supermarket.chef.io). It is narrow in scope for our use cases, but it can be used alongside other cookbooks to extend its use.

## License Required

This cookbook brings up systems that will run Chef premium features. You need to have a license for running more than 25 nodes. See [plans and pricing](https://www.chef.io/chef/#plans-and-pricing) for further details.

## Maintainers and Support

This cookbook is maintained and supported by Chef's engineering services team. This cookbook runs through our internal Chef Delivery system, and changes must be approved by a member of engineering services.

## Requirements

There's a few steps to take to get the provisioning node ready to launch the cluster. This assumes a `chef-repo` is used and the cookbook is being used locally (e.g., berks installed into a vendor path, or a symlink to the cookbook's repository).

It is assumed that these steps are done in the `chef-repo`.

#### Configure ~/.aws/credentials with default credentials

Specify the aws access and secret access keys for the IAM user that should be launching the instances. Specify the region to use. In the Chef AWS account, I was using the us-west-2 (Oregon) region.

```text
[default]
aws_access_key_id=ACCESS-KEY
aws_secret_access_key=SECRET-ACCESS-KEY
region=us-west-2
```

Then set the `AWS_CONFIG_FILE` environment variable to point to it.

```sh
export AWS_CONFIG_FILE=~/.aws/credentials
```

#### Start up Chef Zero

```
./script/launch-zero
```

#### Create a topology data bag item

This data bag item informs configuration options that (may) need to be present in `/etc/opscode/chef-server.rb`.

```json
{
  "id": "topology",
  "topology": "tier",
  "disabled_svcs": [],
  "enabled_svcs": [],
  "vips": [],
  "dark_launch": {
    "actions": true
  },
  "api_fqdn": "api.chef.sh",
  "notification_email": "ops@example.com"
}
```

#### Create a secrets data bag and populate it with the SSH keys

See `./repo/data_bags/secrets/README.md` for details.

In the AWS account, create the `chef-reference-arch` SSH key, and then paste its content into this data bag item, `./repo/data_bags/secrets/chef-reference-arch.json`. Be sure the string values are a single line, replacing actual newlines in the files with `\n`.

```json
{
  "id": "chef-reference-arch",
  "private_ssh_key": "BEGIN RSA KEY blah blah snip",
  "public_ssh_key": "ssh-rsa blah blah blah"
}
```

If you don't use `chef-reference-arch` as the SSH key name, you'll need to change the attributes that refer to that key in the `provision` cookbook.

```
node['chef']['provisioning']['key-name']
node['chef']['provisioning']['machine_options']['bootstrap_options']['key_name']
```

#### Create a "private-chef-secrets" data bag item

See `./repo/data_bags/secrets/README.md` for details.

Create `./repo/data_bags/secrets/private-chef-secrets-_default.json` data bag item with the following content. While `_default` won't be the environment used in "real environments" it is fine for the MVP for minimal configuration required.

```json
{
  "id": "private-chef-secrets-_default",
  "data": {
    "rabbitmq": {
      "password": "SOMETHINGRANDOMLYAWESOMELIKEASHA512",
      "jobs_password": "SOMETHINGRANDOMLYAWESOMELIKEASHA512",
      "actions_password": "SOMETHINGRANDOMLYAWESOMELIKEASHA512"
    },
    "postgresql": {
      "sql_password": "SOMETHINGRANDOMLYAWESOMELIKEASHA512",
      "sql_ro_password": "SOMETHINGRANDOMLYAWESOMELIKEASHA512"
    },
    "oc_id": {
      "sql_password": "SOMETHINGRANDOMLYAWESOMELIKEASHA512",
      "secret_key_base": "SOMETHINGRANDOMLYAWESOMELIKEASHA512"
    },
    "drbd": {
      "shared_secret": "THISISSHORTERTHANTHEOTHERSRANDOMLYGENERATED"
    },
    "keepalived": {
      "vrrp_instance_password": "SOMETHINGRANDOMLYAWESOMELIKEASHA512"
    },
    "oc_bifrost": {
      "superuser_id": "SOMETHINGTHIRTYTWOCHARACTERS",
      "sql_password": "SOMETHINGRANDOMLYAWESOMELIKEASHA512",
      "sql_ro_password": "SOMETHINGRANDOMLYAWESOMELIKEASHA512"
    },
    "bookshelf": {
      "access_key_id": "SOMETHINGTHIRTYTWOCHARACTERS",
      "secret_access_key": "SOMETHINGRANDOMLYAWESOMELIKEASHA512"
    }
  }
}
```

#### Create a "opscode-reporting-secrets-ENV.json" data bag item

See `./repo/data_bags/secrets/README.md` for details.

Where ENV is, by default, `_default`.

These are required for Chef Reporting and Chef Analytics to work properly. Each secret should be the specified number of characters due to the database schema.

```json
{
  "id": "opscode-reporting-secrets-_default",
  "data": {
    "postgresql": {
      "sql_password": "One-hundred characters",
      "sql_ro_password": "One-hundred characters"
    },
    "opscode_reporting": {
      "rabbitmq_password": "One-hundred characters"
    }
  }
}
```

#### Upload the data bags to Chef Zero

```
knife upload /data_bags
```

#### Run rake to build the cluster

```
rake
```

When complete, there will be four nodes:

1. Backend
2. Frontend
3. Analytics
4. Supermarket

Navigate to the frontend FQDN for the Chef Server management console to sign up and get started.

### Platform:

64 bit CentOS 7.1

Other platforms may be added in the future according to the platforms that CHEF supports for Chef Server 12.

### Cookbooks:

* [chef-ingredient](https://github.com/chef-cookbooks/chef-ingredient): manages chef server components/addons and more.

## Attributes

See `attributes/default.rb` for default values.

This cookbook is designed primarily to be used with AWS as that is our use case. However, by modifying the various `driver` attributes, other providers may be usable. This is unsupported, and may require additional configuration consideration.

## Documentation

This README serves as the only documentation for the cookbook at this time.

Chef Server documentation:

* https://docs.chef.io/server/

Chef Server configuration settings:

* http://docs.chef.io/open_source/config_rb_chef_server_optional_settings.html

## Issues

Please report issues in this repository. Please also understand that this cookbook is intended to be narrow and opinionated in scope, and may not work for all use cases.

* https://github.com/chef-cookbooks/chef-reference/issues

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
