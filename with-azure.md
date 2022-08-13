## How To Setup with Azure

### Create and Get a Service Principal

```console
az login
```

You can get your subscriptions.

```console
az account list | jq -r '.[] | "\(.id), \(.name)"'
```

Chose your current subscription.

```console
export SUBSCRIPTION_ID=YOUR_SUBSCRIPTION_ID
```

```console
az account set --subscription=${SUBSCRIPTION_ID}
```

See also https://docs.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest#az-ad-sp-create-for-rbac

```console
az ad sp create-for-rbac --name=provisioning-owner --role="Owner" --scopes=/subscriptions/${SUBSCRIPTION_ID}\
 | tee /project/config/${CURRENT_ENV_NAME}/credentials/azure-service-principal.json
```

## Tips

Show available locations.

```console
az account list-locations
```
