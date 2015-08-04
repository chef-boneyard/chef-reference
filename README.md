# chef-reference

Reference architecture cookbook for building Chef Server, Chef Analytics, and Chef Delivery. This is an open source cookbook and resides in a public GitHub repository. However it is not a "community" cookbook, as it won't be published to the [public Supermarket](https://supermarket.chef.io).

**NOTE** WORK IN PROGRESS.

## Requirements

There's a few steps to take to get the provisioning node ready to launch the cluster. This assumes a `chef-repo` is used and the cookbook is being used locally (e.g., berks installed into a vendor path, or a symlink to the cookbook's repository).

It is assumed that these steps are done in the `chef-repo`.

#### Configure ~/.aws/config with default credentials

Specify the aws access and secret access keys for the IAM user that should be launching the instances. Specify the region to use. In the Chef AWS account, I was using the us-west-2 (Oregon) region.

```text
[default]
aws_access_key_id=ACCESS-KEY
aws_secret_access_key=SECRET-ACCESS-KEY
region=us-west-2
```

#### Start up Chef Zero on port 7799

There's a bug in chef-client's local mode, and I never narrowed it down. Running chef-zero separately worked. Alternatively one could use regular Chef Server like Hosted Chef.

```
chef-zero -l debug -p 7799
```

#### Create a .chef/config.rb

I used `hc-metal-provisioner` as the name of the SSH key pair. It's likely this won't match what you're using, as I have the private key for this and you don't.

```ruby
config_dir = File.dirname(__FILE__)
chef_server_url 'http://localhost:7799'
node_name        'chef-provisioner'
cookbook_path [File.join(config_dir, '..', 'cookbooks')]
```

Change the `chef_server_url` and `node_name` as appropriate if using another Chef Server.

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

```json
{
  "id": "chef-reference-arch",
  "private_ssh_key": "BEGIN RSA KEY blah blah snip",
  "public_ssh_key": "ssh-rsa blah blah blah"
}
```

Be sure the string values are a single line, replacing actual newlines in the files with `\n`.

#### Create a "private-chef-secrets" data bag item

Create `data_bags/secrets/private-chef-secrets-_default.json` data bag item with the following content. While `_default` won't be the environment used in "real environments" it is fine for the MVP for minimal configuration required.

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

#### Upload the cookbook and data bag items to the server

```
knife upload data_bags cookbooks
```

Or if using berks (or policyfiles, at a future date).

```
knife upload data_bags
berks install
berks upload
```

#### Run chef-client on the local system (provisioning node)

```
chef-client -c .chef/knife.rb -o chef-reference::provisioning-cluster
```

The outcome should be:

1. Frontend
2. Backend
3. Analytics

Navigate to https://frontend-fqdn and sign up!

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
