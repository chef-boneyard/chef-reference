Data bag items of secrets for the cluster go here.

The passwords in the Chef Server database have character constraints, so use the same number of characters as these passwords. These were generated randomly on a test node to serve as examples! **IMPORTANT** You should adjust them to your own values when creating the data bag items on your Chef Server.

The secrets data bag items named in each heading should go into this directory (`./repo/data_bags/secrets` from the `chef-reference` cookbook).

**Chef Environments** While this cookbook uses Chef Policies instead of Chef's environments, older iterations of the code base used environments, and we haven't updated that code yet. When we switch to something else we will update the CHANGELOG.md at the toplevel of the cookbook.

## `private-chef-secrets-_default.json`

This is required on all the Chef Server nodes.

Create `private-chef-secrets-_default.json` data bag item with the following content.

```json
{
  "id": "private-chef-secrets-_default",
  "data": {
    "redis_lb": {
      "password": "65287652102ad7dbf4de207eab2c58de51cf7c8917778c37b106d919459765a94a8d56010545ad2d58f2a9fc3dfb2c44d568"
    },
    "rabbitmq": {
      "password": "a64d329c102ad7dbf4de207eab2c58de51cf7c8917778c37b106d919459765a94a8d56010545ad2d58f2a9fc3dfb2c44d568",
      "jobs_password": "b43cad09164c48611c1a4986167310cf1b6110d9be83cce790182c9df30d7da30aeacccadc6b0f042ac060d6077480e3e29f",
      "actions_password": "16c99ae89409d1ba3a086c5dc23f35beb0c83c96ae033b9b0debaf23a23f7a0096d05268f0bdbc1bcaba1dd00c4a855145ab"
    },
    "postgresql": {
      "sql_password": "9cec16d8c87e81e128c19893324c4daf976676a3312b6dc29098ea390bcd3263d1daa51708f9684d2fb73188d37bd3ed63bf",
      "sql_ro_password": "066525f0405a75538247eeec471a27c33b8958d337b6fd352480edf77e81210cc0379d55c4fbcc18c9695ae76ec1a9e52aa1"
    },
    "oc_id": {
      "sql_password": "489231f5a9b7bd443ccce57baa740cadaf0cb1b3f721f5f29ed700c1d96ec4ad083bf97d517db7e86d3d82fea64dc4d93214",
      "secret_key_base": "43598886b7e972b58376d27bccf381695785e7fe4475a8f5b6845131014b635b999219587581c030661d8c72510a550f981d"
    },
    "drbd": {
      "shared_secret": "612ff72d0946fa1a4f946fdde7d4f5a878ee76a78329becdf6198aecee0b"
    },
    "keepalived": {
      "vrrp_instance_password": "c339d987436c044da6e4001017884f4085c256e26636493346d4c7726be43c9dc278d4ecfda4ca38611a7d582166d3680011"
    },
    "oc_bifrost": {
      "superuser_id": "715314998037bb5de5634ac6c20fa495",
      "sql_password": "d20278b005e10407bbe3a0491201858ce15fbc831b191ea0f15098f96c4bf39c767794d799687a3e7962c2c3c5a92cc74701",
      "sql_ro_password": "046389a29c4bdd57fe815f09321a2003bc2ced2eb9c0e23b2ddc6707117f2093038d6928762000f78cfe40168922404e8d29"
    },
    "bookshelf": {
      "access_key_id": "7fae54e8eb6b6fa96a37c2e11a2574132d406378",
      "secret_access_key": "53bafab4e35e455ae1e43c713b73f2cc29f5a430c4a8b8cba463c67a2387a59f9a5e6b7c644884df"
    }
  }
}
```

## `opscode-reporting-secrets-_default.json`

These are required for Chef Reporting (frontend and backend), and Chef Analytics to work properly.

Create `opscode-reporting-secrets-_default.json` data bag item with the following content.

```json
{
  "id": "opscode-reporting-secrets-_default",
  "data": {
    "postgresql": {
      "sql_password": "72bfe1dcef242645853265643468510a0f90a9b8ddfde9808efe680d957fdda37f7818403263fb58230be3fc9b1d9991a894",
      "sql_ro_password": "8c0445aabb157bf40ba6adf165cc7fb3a7114c20529004172ec01bad148c9a81653f272eec7305c8bf35a477fbfc4bb92a73"
    },
    "opscode_reporting": {
      "rabbitmq_password": "ea86a730b23f62fdd1bce56b9e0bfd8c38c769283c1cb29abb2d850283515462d4b47c819890ab285b0eca73f06d5d113c2d"
    }
  }
}
```

## `ssh-key-name.json`

These ssh keys are used by Chef Provisioning in the `provision::cluster` recipe . The name of this data bag item should match these attributes:

```
node['chef']['provisioning']['key-name']
node['chef']['provisioning']['machine_options']['bootstrap_options']['key_name']
```

For example, when using AWS for provisioning by default the `id` is `chef-reference-arch` and the filename is `chef-reference-arch.json`. When using Vagrant for provisioning, the `id` is `vagrant` and the filename is `vagrant.json`.

Be sure the string values are a single line, replacing actual newlines in the files with `\n`. For example, for AWS it would look like this:

```json
{
  "id": "chef-reference-arch",
  "private_ssh_key": "-----BEGIN RSA PRIVATE KEY-----\n ... -----END RSA PRIVATE KEY-----\n"
  "public_ssh_key": "ssh-rsa ....",
}
```

And for Vagrant it looks like this:

```json
{
  "id": "vagrant",
  "private_ssh_key": "-----BEGIN RSA PRIVATE KEY-----\n ... -----END RSA PRIVATE KEY-----\n"
  "public_ssh_key": "ssh-rsa ....",
}
```

Replace the values with the actual public and private SSH keys.
