# Scenario: Custom Policies

This scenario describes how to customize the policies to include a custom cookbook's recipe, and set options from the `chef provision` command to modify how the AWS provisioning is configured.

This scenario combines aspects of the AWS and Alternative Chef Server scenarios as a single standalone document.

## Prerequisites

You must have ChefDK 0.9.0 installed on the provisioning node (e.g., your workstation/laptop), and use `chef shell-init`. For example, if your shell is `bash` or `zsh`:

```
eval "$(chef shell-init `basename $SHELL`)"
```

You must have an AWS account. Set up the aws access and secret access key credentials for the IAM user that should be launching the instances in `~/.aws/config`. Specify the region to use. For example, in Chef's AWS account, we use the us-west-2 (Oregon) region.

```text
[default]
aws_access_key_id=ACCESS-KEY
aws_secret_access_key=SECRET-ACCESS-KEY
region=us-west-2
```

Ensure your AWS account has an SSH key in the `us-west-2` region. Part of this scenario is to use a custom-named key instead of the default `chef-reference-arch`, so name it whatever you like. For example, we will use `chef-2015-10`, and have downloaded the private key to `~/.ssh/chef-2015-10.pem`.

You must create the secrets data bag items as described in `repo/data_bags/secrets/README.md`.

Install the `knife-acl` plugin into ChefDK.

```
chef gem install knife-acl
```

You must have an existing Chef Server to use. For our use case, we will use Hosted Chef, so we don't have to stand up a different Chef Server for our cluster.

Create a configuration file for the alternative Chef Server. This will be used with the commands in this document.

## Create Organization

Sign up on the Chef Server and create a new organization on the Chef Server. For our example, I created the organization `joshuademo` in Hosted Chef.

## Write configuration

Write a `.chef/knife.rb` config file that looks something like this. Change the `chef_server_url` to the correct URL for the organization created earlier. Change the `node_name` to your username. Finally, store your private key somewhere and change `client_key` to point to it. For example, I put mine in `~/.chef/jtimberman.pem`.

This differs from the [alternative chef server doc](./scenario-alternative-chef-server.md) in that it does not have the `repo` directory in the `chef_repo_path`, because we're already in a "chef repo."

```ruby
current_dir = File.dirname(__FILE__)
chef_repo_path File.expand_path(File.join(current_dir, '..'))

chef_server_url 'https://api.chef.io/organizations/joshtest'
node_name 'jtimberman'
client_key File.join(ENV['HOME'], '.chef', 'jtimberman.pem')
```

## Create Provisioner Client

Borrowing from a [blog post](http://jtimberman.housepub.org/blog/2015/02/09/quick-tip-create-a-provisioner-node/) on the matter:

```
knife group create provisioners -c .chef/knife.rb

for i in read create update grant delete
do
  knife acl add containers clients $i group provisioners -c .chef/knife.rb
done

for i in read create update grant delete
do
  knife acl add containers nodes $i group provisioners -c .chef/knife.rb
done

knife client create chef-reference-provisioner -c .chef/knife.rb -d > .chef/chef-reference-provisioner.pem
knife node create -d chef-reference-provisioner -c .chef/knife.rb

knife actor map -c .chef/knife.rb
knife group add actor provisioners chef-reference-provisioner -c .chef/knife.rb
```

## Upload Data Bags

Upload the data bags to the configured Chef Server using `knife`, from the chef-reference top-level directory.

```
knife upload /data_bags -c .chef/knife.rb
```

## Push the Policies

Push the policies to the Chef Server.

```
for policy in server-backend server-frontend analytics supermarket
do
  chef push reference policies/${policy}.rb -c .chef/knife.rb
done
```

### Checkpoint

You should have the following data bags:

```
% knife data bag list -c .chef/knife.rb
chef_server
secrets
```

They should have the following items:

```
% knife data bag show chef_server -c .chef/knife.rb
topology

% knife data bag show secrets -c .chef/knife.rb
chef-reference-arch
opscode-reporting-secrets-_default
private-chef-secrets-_default
```

You should have the following node and client:

```
% knife node list -c .chef/knife.rb
chef-reference-provisioner

% knife client list -c .chef/knife.rb
chef-reference-provisioner
joshuademo-validator
```

You should have the `analytics`, `server-backend`, `server-frontend`, and `supermarket` policies:

```
% knife raw /policies -c .chef/knife.rb
<OUTPUT SNIPPED>
```

And finally, you should have the cookbook artifacts - `chef-reference`, `chef-ingredient`, and the dependencies:

```
% knife raw /cookbook_artifacts -c .chef/knife.rb
<OUTPUT SNIPPED>
```

## Initialize the Cluster

Use the `chef provision` command with the `-o` option to select the custom SSH key we used earlier and the `chef-reference` cookbook's provisioning cookbook. Assuming it is cloned in `~/dev/cookbooks/chef-reference/provision`:

```
chef provision --no-policy --recipe cluster \
  --cookbook ~/dev/cookbooks/chef-reference/provision \
  -o keyname=chef-2015-10
```

This will take approximately 40 minutes because each node will install the omnibus packages for the various server products, and run the reconfigure step for each.

### Checkpoint

See the final Checkpoint section in the [AWS scenario](./scenario-aws.md).
