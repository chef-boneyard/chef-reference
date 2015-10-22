This cookbook is used by Chef's engineering services team to build the Chef Server infrastructure that runs our continuous delivery and integration pipelines used to build Chef products for our customers and the community. It is provided as an example of how we write a "wrapper" cookbook that consumes resources from another cookbook, deliver a cookbook through Chef Delivery, and use the ChefDK `chef provision` command. It is open source so that we can share this with others, but as it runs critical infrastructure for us, it cannot support every use case. It attempts to be as flexible as possible, and provide a common basis which can be extended for other infrastructures.

Our goal is to provide a cookbook that can also show off emerging patterns and practices in the Chef ecosystem, including:

1. Chef Provisioning
1. Chef Policies
1. Chef Delivery

## Chef Provisioning

We use `chef provision` with the `provision` cookbook in this repository. By default, it is configured to use AWS, as that is our reference use case for the CI/CD infrastructure. It also includes a local dev cluster recipe for using Vagrant.

The `Rakefile` at the toplevel of this repository has two tasks, `default` and `dev`. The `default` task will launch the cluster in AWS using `provision::cluster` recipe. See [the AWS scenario doc](./scenario-aws.md). The `dev` task will launch the cluster using Vagrant with the VMware Fusion plugin, but at the time of this writing it isn't working with the latest changes in the cluster recipe.

## Chef Policies

This cookbook uses Chef Policies for dependency resolution and cookbook workflow. At the toplevel, `Policyfile.rb` is used for running the ChefSpec unit tests. The other policies in the `policies` directory are used for the nodes that are brought up for the cluster in the `provision` cookbook. Depending on the state of the world on your local machine, to use the policies you may need to do:

```
chef update
```

to update the `Policyfile.lock.json`, and then:

```
rake update
```

to update all the `policies/*.lock.json`.

## Chef Delivery

We use this cookbook in a Chef Delivery pipeline. The build cookbook is located in the `.delivery/build-cookbook`. This doesn't need to be modified under normal circumstances as it is consumed by Delivery. For local development and testing, Test Kitchen can be used to bring up a local build node to run the verify phase. For example:

```
% cd .delivery/build-cookbook

% kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action
default-ubuntu-1404  Vagrant  ChefZero     Busser    Ssh        <Not Created>
default-centos-71    Vagrant  ChefZero     Busser    Ssh        <Not Created>

% kitchen test default-centos-71
OUTPUT SNIPPED
```
