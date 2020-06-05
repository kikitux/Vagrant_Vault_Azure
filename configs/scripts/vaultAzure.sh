#!/usr/bin/env bash

# Setting Vault Address, it is running on localhost at port 8200
export VAULT_ADDR=http://127.0.0.1:8200

# Setting the Vault Address in Vagrant user bash profile
grep "VAULT_ADDR" ~/.bash_profile  > /dev/null 2>&1 || {
echo "export VAULT_ADDR=http://127.0.0.1:8200" >> ~/.bash_profile
}

echo "Check if Vault is already initialized..."
if [ `vault status -address=${VAULT_ADDR}| awk 'NR==4 {print $2}'` == "true" ]
then
    echo "Vault already initialized...Exiting..."
    exit 1
fi

echo "Making working directory to save keys"
mkdir -p /vagrant/_vaultSetup
touch /vagrant/_vaultSetup/keys.txt

echo "Initializing Vault..."
vault operator init  > /vagrant/_vaultSetup/keys.txt
export VAULT_TOKEN=$(grep 'Initial Root Token:' /vagrant/_vaultSetup/keys.txt | awk '{print substr($NF, 1, length($NF))}')

echo "Unsealing vault..."
vault operator unseal $(grep 'Key 1:' /vagrant/_vaultSetup/keys.txt | awk '{print $NF}') > /dev/null 2>&1
vault operator unseal $(grep 'Key 2:' /vagrant/_vaultSetup/keys.txt | awk '{print $NF}') > /dev/null 2>&1
vault operator unseal $(grep 'Key 3:' /vagrant/_vaultSetup/keys.txt | awk '{print $NF}') > /dev/null 2>&1

echo "Auth with root token..."
vault login token=${VAULT_TOKEN} > /dev/null 2>&1

echo "Creating policy apps using apps-policy.hcl file"
vault policy write apps /vagrant/configs/policies/apps-policy.hcl

echo "Enabiling Azure secrets backend"
vault secrets enable azure

echo "Configuring Azure secrets backend"
vault write azure/config subscription_id="${SUBSCRIPTION_ID}"  \
        client_id="${CLIENT_ID}" client_secret="${SECRET_ID}" \
        tenant_id="${TENANT_ID}"

echo "Configure edu-app role"
vault write azure/roles/edu-app ttl=1h azure_roles=-<<EOF
    [
      {
        "role_name": "Contributor",
        "scope": "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG_NAME}"
      }
    ]
EOF

echo "Getting a token with apps policy attached"
echo -e "Here: \n $(vault token create -policy=apps)"

echo "Set your host machine's VAULT_ADDR to http://127.0.0.1:8200 - export VAULT_ADDR=http://127.0.0.1:8200"
echo "Login with the generated token"
echo "Get credentials from Azure with vault read azure/creds/edu-app"
