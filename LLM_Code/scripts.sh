#!/usr/env/bin bash

# enable disk encrption set
az keyvault set-policy \
  --name gov-il5-kv \
  --object-id <DES_SYSTEM_ASSIGNED_IDENTITY> \
  --key-permissions wrapKey unwrapKey get

# 
