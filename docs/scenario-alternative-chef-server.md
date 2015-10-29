# Scenario: Alternative Chef Server

This scenario describes how to set up an alternative Chef Server to running Chef Zero locally. For the example we'll use Hosted Chef, as that is in line with our use case.

## Prerequisites

You must have ChefDK 0.9.0 installed on the provisioning node (e.g., your workstation/laptop), and use `chef shell-init`. For example, if your shell is `bash` or `zsh`:

```
eval "$(chef shell-init `basename $SHELL`)"
```

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

```ruby
current_dir = File.dirname(__FILE__)
chef_repo_path File.expand_path(File.join(current_dir, '..', 'repo'))

chef_server_url 'https://api.chef.io/organizations/joshuademo'
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
  knife acl add containers nodes $i group provisioners -c .chef/knife.rb
done

for i in read create update delete
do
  knife acl add containers sandboxes $i group provisioners -c .chef/knife.rb
  knife acl add containers cookbook_artifacts $i group provisioners -c .chef/knife.rb
  knife acl add containers policies $i group provisioners -c .chef/knife.rb
  knife acl add containers policy_groups $i group provisioners -c .chef/knife.rb
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

While we have a `rake` task that will handle updating the policies, pushing them to the server, and initializing the cluster, we need to use our custom configuration with the `chef provision` command. Do that with:

```
chef provision --no-policy --recipe cluster -c .chef/knife.rb
```

This will take approximately 40 minutes because each node will install the omnibus packages for the various server products, and run the reconfigure step for each.

### Checkpoint

See the final Checkpoint section in [scenario-aws.md](./scenario-aws.md).
