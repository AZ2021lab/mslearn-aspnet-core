#!/bin/bash

# Color theming
if [ -f ~/clouddrive/aspnet-learn/setup/theme.sh ]
then
  eval $(cat ~/clouddrive/aspnet-learn/src/setup/theme.sh)
fi

acr=$REGISTRY
lbIp=$ESHOP_LBIP

eshopRegistry=${ESHOP_REGISTRY}

if [ -z "$acr" ]&&[ ! -z "$eshopRegistry" ]
then
    acr=$eshopRegistry
fi

while [ "$1" != "" ]; do
    case $1 in
        --acr)                          shift
                                        acr=$1
                                        ;;
        --ip)                           shift
                                        lbIp=$1
                                        ;;
       * )                              echo "Invalid param: $1"
                                        exit 1
    esac
    shift
done

if [ -z "$acr" ]
then
    echo "${newline}${errorStyle}Must set and export environment variable called REGISTRY with ACR login server or use --acr${defaultTextStyle}${newline}"
    exit 1
fi

if [ -z "$lbIp" ]
then
    echo "${newline}${errorStyle}ERROR: Load balancer IP needed. Please use --ip parameter.${defaultTextStyle}${newline}"
    exit 1
fi

echo
echo "Deploying Helm charts using registry \"$acr\""

for dir in ./helm-simple/*/
do
    dir=${dir%*/}
    chart=${dir##*/}
    echo
    echo "Installing chart \"$chart\"..."
    helmCmd="helm install eshop-$chart --set registry=$acr --set aksLB=$lbIp \"helm-simple/$chart\""
    echo "${newline} > ${genericCommandStyle}$helmCmd${defaultTextStyle}${newline}"
    eval $helmCmd
done

echo
echo "Helm charts deployed"
helm list

echo
echo "Pod status"
kubectl get pods

pushd ~/clouddrive/aspnet-learn
echo "The eShop-Learn application has been deployed." > deployment-urls.txt
echo "" >> deployment-urls.txt
echo "You can begin exploring these services (when available):" >> deployment-urls.txt
echo "- Centralized logging       : http://$lbIp/seq/#/events?autorefresh (See transient failures during startup)" >> deployment-urls.txt
echo "- General application status: http://$lbIp/webstatus/ (See overall service status)" >> deployment-urls.txt
echo "- Web SPA application       : http://$lbIp/" >> deployment-urls.txt
echo "" >> deployment-urls.txt
popd