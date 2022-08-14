# Example for Azure Application Gateway with Virtual Machine

[![default](https://github.com/mazgi-showcase/202208.azure-appgw-with-vm/actions/workflows/default.yml/badge.svg)](https://github.com/mazgi-showcase/202208.azure-appgw-with-vm/actions/workflows/default.yml)

![structure](docs/images/drawing/drawing.001.png)

## How to set up

You need one Azure subscription you can fully manage.  
And you need to get credentials after setting up system accounts for provisioning as described below.

### How to set up your Azure service principal

You should create an Azure service principal that added follows roles.

- `Contributor`

### How to set up your local environment

You need create the `.env` file as follows.

```
CURRENT_ENV_NAME=production
PROJECT_UNIQUE_ID=YOUR_UNIQUE_ID_AS_A_RESOURCE_PREFIX
AZURE_DEFAULT_LOCATION="Central US"
ARM_SUBSCRIPTION_ID=********
ARM_CLIENT_ID=********
ARM_CLIENT_SECRET=********
ARM_TENANT_ID=********
```

```console
echo TF_VAR_allowed_ipaddr_list='["'$(curl -sL ifconfig.io)'/32"]' >> .env
```

If you are using Linux, you should add UID and GID to the `.env` file as follows.

```shellsession
test $(uname -s) = 'Linux' && echo "UID=$(id -u)\nGID=$(id -g)" >> .env
```

## How to run

Now you can make provisioning as follows.

```shellsession
docker compose up --detach && docker compose logs --follow
^c
```

```shellsession
docker compose exec provisioning terraform plan
docker compose exec provisioning terraform fmt -recursive
docker compose exec provisioning terraform apply -auto-approve
```

## How to Verify the Environment you created

### via Application Gateway

| "Host" request header | HTTP Status Code | "X-ServerName" response header |
| --------------------- | ---------------- | ------------------------------ |
| --                    | 404              | --                             |
| blue.example.com      | 200              | blue.example.com               |
| green.example.com     | 200              | green.example.com              |

```console
❯ curl -sI $AppGwPubIp | grep -E '^(HTTP/|Server|X-ServerName):?'
HTTP/1.1 404 Not Found
Server: Microsoft-Azure-Application-Gateway/v2
```

```console
❯ curl -sI $AppGwPubIp -H 'Host: blue.example.com' | grep -E '^(HTTP/|Server|X-ServerName):?'
HTTP/1.1 200 OK
Server: nginx/1.18.0 (Ubuntu)
X-ServerName: blue.example.com
```

```console
❯ curl -sI $AppGwPubIp -H 'Host: green.example.com' | grep -E '^(HTTP/|Server|X-ServerName):?'
HTTP/1.1 200 OK
Server: nginx/1.18.0 (Ubuntu)
X-ServerName: green.example.com
```

### via VM Blue

| "Host" request header | HTTP Status Code | "X-ServerName" response header |
| --------------------- | ---------------- | ------------------------------ |
| --                    | 200              | --                             |
| blue.example.com      | 200              | blue.example.com               |
| green.example.com     | 200              | --                             |

```console
❯ curl -sI $VMBluePubIp | grep -E '^(HTTP/|Server|X-ServerName):?'
HTTP/1.1 200 OK
Server: nginx/1.18.0 (Ubuntu)
```

```console
❯ curl -sI $VMBluePubIp -H 'Host: blue.example.com' | grep -E '^(HTTP/|Server|X-ServerName):?'
HTTP/1.1 200 OK
Server: nginx/1.18.0 (Ubuntu)
X-ServerName: blue.example.com
```

```console
❯ curl -sI $VMBluePubIp -H 'Host: green.example.com' | grep -E '^(HTTP/|Server|X-ServerName):?'
HTTP/1.1 200 OK
Server: nginx/1.18.0 (Ubuntu)
```

### via VM Green

| "Host" request header | HTTP Status Code | "X-ServerName" response header |
| --------------------- | ---------------- | ------------------------------ |
| --                    | 200              | --                             |
| blue.example.com      | 200              | --                             |
| green.example.com     | 200              | green.example.com              |

```console
❯ curl -sI $VMGreenPubIp | grep -E '^(HTTP/|Server|X-ServerName):?'
HTTP/1.1 200 OK
Server: nginx/1.18.0 (Ubuntu)
```

```console
❯ curl -sI $VMGreenPubIp -H 'Host: blue.example.com' | grep -E '^(HTTP/|Server|X-ServerName):?'
HTTP/1.1 200 OK
Server: nginx/1.18.0 (Ubuntu)
```

```console
❯ curl -sI $VMGreenPubIp -H 'Host: green.example.com' | grep -E '^(HTTP/|Server|X-ServerName):?'
HTTP/1.1 200 OK
Server: nginx/1.18.0 (Ubuntu)
X-ServerName: green.example.com
```
