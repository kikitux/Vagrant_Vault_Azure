# Simple repository that tries to demonstrate how to use Azure secrets backend in Hashicorp Vault.


### Prerequisites

- Vagrant
- Azure account
- Vault client on the host machine

### How to use it :

- Clone the repository with `git clone`
- Setup the following environment variables :
```
export TENANT_ID=YOUR_TENANT_ID
export CLIENT_ID=YOUR_CLIENT_ID
export SECRET_ID=YOUR_SECRET_ID
export SUBSCRIPTION_ID=YOUR_SUBSCRIPTION_ID
export RG_NAME=YOUR_RG_NAME
```
In order to retrieve the information needed for setting the environment variables you can fallow [this](https://learn.hashicorp.com/vault/secrets-management/azure-creds) guide.

- Execute `vagrant up`
- Setup your Vault server address with `export VAULT_ADDR=http://127.0.0.1:8200`
- Login with the token presented to you by Vagrant.
- Retrieve credentials from Azure by executing `vault read azure/creds/edu-app`
- The output should look like :
```
Key                Value
---                -----
lease_id           azure/creds/edu-app/oNe**********************
lease_duration     1h
lease_renewable    true
client_id          88af8726-*******-*******-*******-**********************
client_secret      e0925f07-*******-*******-*******-**********************
```


Note: The repository is based on [this](https://learn.hashicorp.com/vault/secrets-management/azure-creds) guide.
