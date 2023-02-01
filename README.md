# KIT-IT_platform
# Выполнено ДЗ № 1

 - [X] Основное ДЗ
 - [X] Задание со *

## В процессе сделано:
 - Установили VM Centos 8, zsh, oh-my-zsh.
 - Установили docker, kubectl, Minikube, k9s.
 - Создали пользвателя docker, так как из под root не стартовал minikube.
 - Запустили minikube start
 - Потренеровались запускать pods
    - Восстановление происходит за счет того, что kubedns управлеяется replicaset, которые созданы deployment.
      kube-apiserver управляется сервисом kubelet и его манифест хранится на файловой системе мастер-ноды.
 - Создали Dockerfile с простым nginx веб сервером. Залили в docker hub.
 - Запустили в k8s. Научились запускать и анализировать состояния.
 - Клонировали из GITHUB проект frontend.
 - Создали образ с фронтентодом. И запушен под. Не хватало кучки переменных.

## Как запустить проект:
 - kubectl apply -f frontend-pod-healthy.yaml

## Как проверить работоспособность:
 - Перейти по ссылке http://localhost:8080

## PR checklist:
 - [X] Выставлен label с темой домашнего задания


# Выполнено ДЗ № 2

  - [X] Основное ДЗ
  - [X] Задание со *

## В процессе сделано:
  - Установили kind. Методичка устарела, поэтому:
    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
  - Создали кластер. Я уж думал, что виртуалка умерла. Загрузка бешенная - на 100 процентов CPU.
    kind create cluster --config kind-config.yaml
    kubectl get nodes - проверили ноды
  - Добавили переменные в секцю env и секцию selector в frontend-replicaset.yaml
    kubectl apply -f frontend-replicaset.yaml
    kubectl get pods -l app=frontend
  - Сделали 3 реплики
    kubectl scale replicaset frontend --replicas=3
    kubectl get rs frontend
  - Проверили, что после удаления, поды восстанавливаются
    kubectl delete pods -l app=frontend
    kubectl get pods -l app=frontend -w
  - Повторно применили манифест и убедились, что реплик стало снова 1.
  - Перетегировали образ и запустили манифест с новой версией образа.
    kubectl apply -f frontend-replicaset.yaml | kubectl get pods -l app=frontend -w
    kubectl get replicaset frontend -o=jsonpath='{.spec.template.spec.containers[0].image}'
      kitit/hipstershop:v.0.0.2
    kubectl get pods -l app=frontend -o=jsonpath='{.items[0:3].spec.containers[0].image}'
      kitit/hipstershop kitit/hipstershop kitit/hipstershop% 
  - Почему обновление ReplicaSet не повлекло обновление запуенных pod?
    Потому что идентификатор образа одинаковый и не важно какой у него тег. Так же перетегированный образ не пулится в docker hub, а просто обновляется.
  - Поместили образа в докер хаб.
  - Подготовили манифесты paymentservice-replicaset.yaml paymentservice-deployment.yaml и запустили их.
    kubectl apply -f paymentservice-replicaset.yaml | kubectl get pods -l app=paymentservice -w
    kubectl apply -f paymentservice-deployment.yaml | kubectl get pods -l app=paymentservice -w
    kubectl get deployments
    NAME         READY   UP-TO-DATE   AVAILABLE   AGE
    paymentsrv   3/3     3            3           3m17s
    kubectl get rs
    NAME                    DESIRED   CURRENT   READY   AGE
    paymentservice          3         3         3       6m6s
    paymentsrv-5c7455fd9c   3         3         3       3m25s
    Обновление Deployemnt
    kubectl rollout history deployment paymentsrv
    kubectl rollout undo deployment paymentsrv --to-revision=1 | kubectl get rs -l app=paymentservice -w
  - Выполнли задание с звездочкой. Развернули аналоги blue-green paymentservice-deployment-bg.yaml и Rolling Update paymentservice-deployment-reverse.yaml
  - Создали манифест frontend-deployment.yaml и посмотрели, как используются Probes.
  - 

## Как запустить проект:
  - 

## Как проверить работоспособность:
  - Перейти по ссылке http://localhost:8080

## PR checklist:
  - [X] Выставлен label с темой домашнего задания


# Выполнено ДЗ № 4

  - [X] Основное ДЗ
  - [X] Задание со *

## В процессе сделано:
  - kubectl apply -f web-deploy.yaml
  - kubectl delete pod/web --grace-period=0 --force
  - kubectl describe deployment web
  - создадим манифест для нашего сервиса в папке kubernetesnetworks. Файл web-svc-cip.yaml
    kubectl apply -f web-svc-cip.yaml
  - minikube ssh
    iptables --list -nv -t nat
  - Измените значение mode с пустого на ipvs и добавьте параметр strictARP: true и сохраните изменения
    kubectl edit configmap -n kube-system kube-proxy
    apiVersion: kubeproxy.config.k8s.io/v1alpha1
    kind: KubeProxyConfiguration
    mode: "ipvs"
    ipvs:
      strictARP: true
  - Теперь удалим Pod с kube-proxy , чтобы применить новую конфигурацию (он входит в DaemonSet и будет запущен автоматически)
    kubectl --namespace kube-system delete pod --selector='k8s-app=kube-proxy'
  - minikube ssh
    iptables --list -nv -t nat
    sudo touch /tmp/iptables.cleanup
    ---
    *nat
    -A POSTROUTING -s 172.17.0.0/16 ! -o docker0 -j MASQUERADE
    COMMIT
    *filter
    COMMIT
    *mangle
    COMMIT
    ---
    sudo iptables-restore /tmp/iptables.cleanup
    iptables --list -nv -t nat
  - toolbox not faund - в целом, конечно, задумка совершена по очистке. Судя по ip addr show kube-ipvs0.
  - kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/namespace.yaml
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/metallb.yaml
    kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
  - touch metallb-config.yaml
    inet 192.168.49.2/24 brd 192.168.49.255 scope global eth0
    sudo route add 172.17.255.0/24 192.168.49.2
  - kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/deploy.yaml
    kubectl get service -n ingress-nginx
    curl -vvvk http://172.17.255.2:80  
  - 

## Как запустить проект:
  - 

## Как проверить работоспособность:
  - Перейти по ссылке http://localhost:8080

## PR checklist:
  - [X] Выставлен label с темой домашнего задания

# Выполнено ДЗ № 5 kubernetes-volumes

  - [X] Основное ДЗ
  - [X] Задание со *

## В процессе сделано:
  - kind create cluster  
  - kubectl cluster-info --context kind-kind
  - export KUBECONFIG="$(kind get kubeconfig --name="kind")"
    kubeconfig-path - нет такого.
  - kubectl apply -f https://raw.githubusercontent.com/express42/otus-platform-snippets/master/Module-02/Kuberenetes-volumes/minio-statefulset.yaml
  - kubectl apply -f https://raw.githubusercontent.com/express42/otus-platform-snippets/master/Module-02/Kuberenetes-volumes/minio-headless-service.yaml
  - kubectl get statefulsets
    kubectl get pods
    kubectl get pvc
    kubectl get pv
    kubectl describe <resource> <resource_name>
  - Задание с *
    Добавили kind: Secret и указали в манифесте секреты и значения к ним.
    secret/minio-secret created
    statefulset.apps/minio configured
  - kind delete cluster
    Deleting cluster "kind" ...

## Как запустить проект:
  - Задеплоить манифесты

## Как проверить работоспособность:
  - Задеплоить манифесты и проверить через запросы состояния

## PR checklist:
  - [X] Выставлен label с темой домашнего задания


# Выполнено ДЗ № 6 kubernetes-templating

  - [X] Основное ДЗ
  - [X] Задание со *

## В процессе сделано:
  - kubectl apply -f web-deploy.yaml
  - kubectl delete pod/web --grace-period=0 --force
  - kubectl describe deployment web
  - создадим манифест для нашего сервиса в папке kubernetesnetworks. Файл web-svc-cip.yaml
    kubectl apply -f web-svc-cip.yaml
  - minikube ssh
    iptables --list -nv -t nat
  - Измените значение mode с пустого на ipvs и добавьте параметр strictARP: true и сохраните изменения
    kubectl edit configmap -n kube-system kube-proxy
    apiVersion: kubeproxy.config.k8s.io/v1alpha1
    kind: KubeProxyConfiguration
    mode: "ipvs"
    ipvs:
      strictARP: true
  - Теперь удалим Pod с kube-proxy , чтобы применить новую конфигурацию (он входит в DaemonSet и будет запущен автоматически)
    kubectl --namespace kube-system delete pod --selector='k8s-app=kube-proxy'
  - minikube ssh
    iptables --list -nv -t nat
    sudo touch /tmp/iptables.cleanup
    ---
    *nat
    -A POSTROUTING -s 172.17.0.0/16 ! -o docker0 -j MASQUERADE
    COMMIT
    *filter
    COMMIT
    *mangle
    COMMIT
    ---
    sudo iptables-restore /tmp/iptables.cleanup
    iptables --list -nv -t nat
  - toolbox not faund - в целом, конечно, задумка совершена по очистке. Судя по ip addr show kube-ipvs0.
  - kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/namespace.yaml
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/metallb.yaml
    kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
  - touch metallb-config.yaml
    inet 192.168.49.2/24 brd 192.168.49.255 scope global eth0
    sudo route add 172.17.255.0/24 192.168.49.2
  - kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/deploy.yaml
    kubectl get service -n ingress-nginx
    curl -vvvk http://172.17.255.2:80  
  - 

## Как запустить проект:
  - 

## Как проверить работоспособность:
  - Перейти по ссылке http://localhost:8080

## PR checklist:
  - [X] Выставлен label с темой домашнего задания

# Выполнено ДЗ № 5 kubernetes-volumes

  - [X] Основное ДЗ
  - [X] Задание со *

## В процессе сделано:
  - GC в связи с операцией недоступен, поэтому выполняем работу в YC.
  - Зарегистрировались, установили CLi YC, сделали сервисный аккаунт С РОЛЬЮ admin. yc config list
    token: AQAAAAAM**************atnAQCZggbC4A
    cloud-id: b1g6v5s594gnrffcntf6
    folder-id: b1g484bj5rqea9ljk25h
    compute-default-zone: ru-central1-b
  - yc iam service-account create --name docker \
    --description "This is my favorite service account for OTUS"
    id: ajede3ank9simde8m52d
    folder_id: b1g484bj5rqea9ljk25h
    created_at: "2022-04-06T14:39:28.135041510Z"
    name: docker
    description: This is my favorite service account for OTUS
  - В YC создаем облачную сеть
  - Создаем кластер managed
  - Добавляем учетные данные кластера в k8s
    yc managed-kubernetes cluster get-credentials managed --external
    По умолчанию учетные данные добавляются в директорию $HOME/.kube/config
    Если необходимо изменить расположение конфигураций, используйте флаг --kubeconfig <путь к файлу>
    Context 'yc-managed' was added as default to kubeconfig '/home/docker/.kube/config'.
    Check connection to cluster using 'kubectl cluster-info --kubeconfig /home/docker/.kube/config'.
    Kubernetes control plane is running at https://51.250.46.16
    CoreDNS is running at https://51.250.46.16/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
    Metrics-server is running at https://51.250.46.16/api/v1/namespaces/kube-system/services/https:metrics-server:/proxy
  - kubectl config view
  - Установили HELM version.BuildInfo{Version:"v3.8.0"
  - helm repo add stable https://charts.helm.sh/stable
    "stable" has been added to your repositories
  - nginx-ingress.
    kubectl create ns nginx-ingress - создали неймспейс под nginx   
    Создали рабочий узел для k8s, ключи и по инструкции, а так же влоэженным инструкциям ingress-controller.
    Команды после ссылки
    https://cloud.yandex.ru/docs/application-load-balancer/operations/k8s-ingress-controller-install
    helm install ingress-nginx ingress-nginx/ingress-nginx --namespace=nginx-ingress - выполняется долго. Смотрим в дашборд "Рабочая нагрузка". Там видим, что полнимается конктроллер в пространстве имен nginx-ingress.
    You can watch the status by running 'kubectl --namespace nginx-ingress get services -o wide -w ingress-nginx-controller'
    Созданный контроллер смотрим в Yandex Network Load Balancer.
  - cert-manager
    Установите менеджер сертификатов
    https://cloud.yandex.ru/docs/managed-kubernetes/tutorials/ingress-cert-manager
    На данный момент https://github.com/cert-manager/cert-manager/releases - 1.8.0 последняя версия.
    kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.8.0/cert-manager.yaml
    Сразу создается неймспейс namespace/cert-manager created и запускаются поды.
    kubectl get pods -n cert-manager --watch
  - chartmuseum
    По ссылке https://github.com/kubernetes/ingress-nginx/blob/main/charts/ingress-nginx/values.yaml
    в самом низу определили, что нам нужен ingress.
    Сделали свой values.yaml, используя EXTERNAL-IP из kubectl --namespace nginx-ingress get services -o wide -w ingress-nginx-controller
    kubectl create ns chartmuseum
    helm upgrade --install chartmuseum stable/chartmuseum --wait \
    --namespace=chartmuseum \
    --version=2.13.2 \
    -f kubernetes-templating/chartmuseum/values.yaml
    Выдал сообщение W0412 22:58:23.453819   74416 warnings.go:70] networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
    но статус STATUS: deployed, а так же подсказку:
    Get the ChartMuseum URL by running:
    export POD_NAME=$(kubectl get pods --namespace chartmuseum -l "app=chartmuseum" -l "release=chartmuseum" -o jsonpath="{.items[0].metadata.name}")
    echo http://127.0.0.1:8080/
    kubectl port-forward $POD_NAME 8080:8080 --namespace chartmuseum

    helm ls -n chartmuseum - проверим установку
    В Helm3 данные секретов хранятся в kubectl get secrets -n chartmuseum
    Chartmuseum доступен по URL https://51.250.35.129.nip.io/, тут ошибка небольшая у меня была. В values.yaml надо было hosts прописывать именно так https://chartmuseum.<IP>.nip.io,
    тогда открылось бы правильно.
  - Задание с зведочкой:*******************************************
    helm repo add chartmuseum http://51.250.35.129.nip.io/- Добавяем репозиторий HTTP, с HTTPS ошибка
    Error: looks like "https://51.250.35.129.nip.io" is not a valid chart repository or cannot be reached: Get "https://51.250.35.129.nip.io/index.yaml": x509: certificate is valid for ingress.local, not 51.250.35.129.nip.io
    Перешли на офф статью https://github.com/helm/chartmuseum
    helm plugin install https://github.com/chartmuseum/helm-push - установлен плагин helm-push https://github.com/chartmuseum/helm-push
    Посмотрел ADV-TV на ютубе. Взял по видео созданный чарт https://github.com/adv4000/k8s-lessons
    Положил чарт в созданный каталог charttest и запустил helm install app ../charttest. Придожение поднялось и доступно по http и EXTERNAL-IP LoadBalancer
    Посмотрел в списке через команду helm list и естественно удалил helm delete app 
    Далее запоковал в tar helm package charttest, создался chartmuseum/App-HelmChart-0.1.0.tgz
    helm upgrade --install chartmuseum stable/chartmuseum --wait --namespace=chartmuseum --version=1.8.0 -f values.yaml --set env.open.DISABLE_API=false
    helm cm-push charttest/ chartmuseum
    helm repo update
    helm search repo -l chartmuseum/
    ***************************************************************
  - harbor
    helm repo add harbor https://helm.goharbor.io
    kubectl create ns harbor
    helm install harborotus -n harbor harbor/harbor
    helm upgrade --install harborotus harbor/harbor --wait \
    --namespace=harbor \
    --version=1.1.2 \
    -f values.yaml
    Заходим в harbor https://harbor.51.250.35.129.nip.io/harbor/sign-in?redirect_url=%2Fharbor%2Fprojects
  - Создаем свой helm chart
    helm create kubernetes-templating/hipster-shop
    Creating kubernetes-templating/hipster-shop
    WARNING: File "/home/docker/OTUS/GIT/KIT-IT_platform/kubernetes-templating/hipster-shop/Chart.yaml" already exists. Overwriting.
    kubectl create ns hipster-shop
    helm upgrade --install hipster-shop kubernetes-templating/hipster-shop --namespace hipster-shop
    helm create kubernetes-templating/frontend
    helm upgrade --install frontend kubernetes-templating/frontend --namespace hipster-shop
    https://shop.51.250.35.129.nip.io/ - кайф, запустилось. Были проблемы с памятью, добавил и поднялося.
    Прописали переменные в values.yaml
    helm upgrade --install frontend kubernetes-templating/frontend --namespace hipster-shop - ничего не изменилось, все работает
    helm delete frontend -n hipster-shop
    Добавили chart frontend как зависимость к chart hipster-shop
    helm dep update kubernetes-templating/hipster-shop
    helm list -n hipster-shop
    helm upgrade --install hipster-shop kubernetes-templating/hipster-shop --namespace hipster-shop --set frontend.service.NodePort=31234
  - kubecfg
    sudo install kubecfg-linux-amd64 /usr/local/bin/kubecfg

## Как запустить проект:
  - Задеплоить манифесты

## Как проверить работоспособность:
  - Задеплоить манифесты и проверить через запросы состояния

## PR checklist:
  - [X] Выставлен label с темой домашнего задания

 Выполнено ДЗ № 6 kubernetes-operators

  - [X] Основное ДЗ
  - [X] Задание со *

## В процессе сделано:
  - minikube start
  - kubectl apply -f deploy/crd.yml
  - kubectl apply -f deploy/cr.yml
  - kubectl get crd
    NAME                   CREATED AT
    mysqls.otus.homework   2023-02-01T19:02:23Z
  - kubectl get mysqls.otus.homework
    NAME             AGE
    mysql-instance   3m
  - kubectl delete mysqls.otus.homework mysql-instance
  - {11:33PM}docker@localhost:~/OTUS/GIT/KIT-IT_platform/kubernetes-operators/deploy@kubernetes-operators✗✗ > kubectl get jobs
    NAME                         COMPLETIONS   DURATION   AGE
    backup-mysql-instance-job    1/1           0s         2m46s
    restore-mysql-instance-job   1/1           41s        97s
  - {11:34PM}docker@localhost:~/OTUS/GIT/KIT-IT_platform/kubernetes-operators/deploy@kubernetes-operators✗✗ > export MYSQLPOD=$(kubectl get pods -l app=mysql-instance -o jsonpath="{.items[*].metadata.name}")
    kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "select * from test;" otus-database
    mysql: [Warning] Using a password on the command line interface can be insecure.
    +----+-------------+
    | id | name        |
    +----+-------------+
    |  1 | some data   |
    |  2 | some data-2 |

## Как запустить проект:
  - Задеплоить манифесты

## Как проверить работоспособность:
  - Задеплоить манифесты и проверить через запросы состояния

## PR checklist:
  - [X] Выставлен label с темой домашнего задания
