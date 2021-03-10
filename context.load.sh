#!/bin/bash
source context.inventory
echo "----------"
echo $K8S_ENV_SITE_HOST
for kenvsitehost in ${K8S_ENV_SITE_HOST[@]};
do
    echo "kenvsitehost: $kenvsitehost"
    kenv="${kenvsitehost%%+*}"
    ksitehost="${kenvsitehost##*+}"
    ksite="${ksitehost%%-*}"
    khost="https://${ksitehost##*-}"
    echo "kenv: $kenv"
    echo "ksite: $ksite"
    echo "khost: $khost"
    ksitecertfile="inventory/$ksite.cert"
    ksitecert=$(cat $ksitecertfile)
    ksitetokenfile="inventory/$ksite.token"
    ksitetoken=$(cat $ksitetokenfile)
    echo $ksitecertfile
    kcluster="$kenv-$ksite-$khost"
    kcredential="gitlab-service-account-$ksite"
    kcontext="$kenv-$ksite-context"
    echo "Create cluster $kcluster"    
    kubectl config set-cluster $kcluster --server="$khost" --certificate-authority=$ksitecertfile
    echo "Create user $kcredential"
    kubectl config set-credentials $kcredential --token=$ksitetoken
    echo "Create context $kcontext"
    kubectl config set-context $kcontext --cluster=$kcluster --user=$kcredential --namespace=default
    echo "Test context $kcontext"
    kubectl config use-context $kcontext
    kubectl get node

    echo "$kcontext" >> "$kenv.context"
done
