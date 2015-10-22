# Scenario: AWS

This scenario describes how to stand up a default cluster in Amazon Web Services with `chef-reference`. The instructions here use the defaults from `chef-reference` and `provision` cookbooks.

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

Ensure your AWS account has an SSH key in the `us-west-2` region named `chef-reference-arch` and use it in the secrets step, next.

You must create the secrets data bag items as described in `repo/data_bags/secrets/README.md`.

## Start Chef Zero

Open a new terminal in the the toplevel `chef-reference` repository directory, and start start Chef Zero with the `launch-zero` script.

```
% ./script/launch-zero
I have started chef-zero at chefzero://localhost:7788.
Hit Ctrl + C to end.
```

## Upload Data Bags

Upload the data bags to the Chef Zero server started in the previous step using `knife`, from the chef-reference top-level directory.

```
knife upload /data_bags
```

### Checkpoint

You should have the following data bags:

```
% knife data bag list
chef_server
secrets
```

They should have the following items:

```
% knife data bag show chef_server
topology

% knife data bag show secrets
chef-reference-arch
opscode-reporting-secrets-_default
private-chef-secrets-_default
```

## Initialize the Cluster

We have a `rake` task that handles uploading the Chef Policies and cookbooks to the Chef Zero server, and then uses `chef provision` to launch the cluster.

```
rake
```

This will take approximately 40 minutes because each node will install the omnibus packages for the various server products, and run the reconfigure step for each.

### Checkpoint

Once the `chef provision` run is complete, we'll have four m3.medium RHEL 7 instances:

- Chef Server backend with Reporting
- Chef Server frontend with Reporting and Manage, available as `chef.example.com`
- Chef Analytics standalone, available at `analytics.example.com`
- Supermarket, available as `supermarket.example.com`

We use example.com [as an example](https://tools.ietf.org/html/rfc2606). See `scenario-custom-fqdn.md` for steps to take to customize the public hostnames for the cluster.

To access the systems for testing purposes, add entries to your local system's `hosts` file, e.g. `/etc/hosts`. You can get the IPs from the `chef-zero` server that was started earlier using `knife exec script/hosts-entries`.

```
% knife exec script/hosts-entries
54.149.252.142 analytics.example.com
54.148.144.50 chef.example.com
54.186.41.241 supermarket.example.com
```

You'll need to allow traffic through the security group where the instances were launched. That is out of scope from this document, however. Once that is complete, you can navigate to `https://chef.example.com` to get started. We use self-signed SSL certificates by default, so your browser will probably issue warnings about untrusted certificates.
