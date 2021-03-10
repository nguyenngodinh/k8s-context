# k8s context
## Component
1. Inventory
- inventory.context
            define site's information: environment, site, site's host.

            K8S_ENV_SITE_HOST=("[environment name]+[site name]-[k8s cluster address]")
- inventory
            store k8s site's certificate, token.

            [site name].cert

            [site name].token
2. Context load
- context.load.sh utility for loading site's k8s context

3. Require
- To use kubernetes cluster context, the host machine must be installed kubectl

## How to initialize the context
1. Define the k8s environment in inventory.context
2. Collect the k8s environment certificate, and token
    - k8s site certificate: 
        - List secrets: 
            ```
            kubectl get secrets (one should be named similar to default-token-xxxxx)
            ```
        - Get the certificate: 
            ```
            kubectl get secret <secret name> -o jsonpath="{['data']['ca\.crt']}" | base64 --decode
            ```
    - k8s account token:
        - Create account: 
            ```
            kubectl apply -f k8s-admin-service-account.yaml
            ```
        - Retrieve token for the account: 
            ```
            kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep gitlab | awk '{print $1}')
            ```

## How k8s context work
1. Load contexts
    context.load.sh
2. Use context
    ```
    kubectl config use-context [context name]
    ```
3. List the context by environment

    ```
    contexts=$(cat "$KENV.context" | tr '\n' ' ')
    for context in $contexts;
    do
        kubectl config use-context $context
    done
    ```

P/s: 
context name's format: "[env name]-[site name]-context"

example: develop-site01-context

## How to use k8s-context in source code porject to auto deploy in multiple k8s cluster
1. Add k8s-context as a submodule in git project
2. Have deploy stuff to apply in k8s cluster
3. Write gitlab CI task to deploy

- deploy task's variables: 

    KENV ~ environment name

    KSITE ~ site name
- deploy to all site belong to env: 

    set KENV to specific environment name

    set KSITE to empty

    example: KENV=develop KSITE=''
- deploy to a specific site:

    set KENV to speicific environment name

    set KSITE to specific site name
    
    example: KENV=test KSITE=site01
```
stages:
    - build
    - test
    - package
    - deploy

......

vccus_deploy_test:
  stage: deploy
  when: manual
  only:
    - master
  variables:
    KENV: test
  script:
  - ./vccus.deploy.sh $KENV $KSITE
```



