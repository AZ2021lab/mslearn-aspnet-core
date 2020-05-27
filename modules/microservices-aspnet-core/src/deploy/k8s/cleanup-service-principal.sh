#!/bin/bash

# Color theming
if [ -f ~/clouddrive/aspnet-learn/setup/theme.sh ]
then
  eval $(cat ~/clouddrive/aspnet-learn/src/setup/theme.sh)
fi

echo "Deleting service principal(s)..."

while IFS= read -r appId
do
    echo "${newline} > ${azCliCommandStyle}az ad sp delete --id $appId${defaultTextStyle}${newline}"
    az ad sp delete --id $appId
done < <(az ad sp list --show-mine --query "[?contains(displayName,'eShop-Learn-AKS')].appId" --output tsv)

echo "Done!"