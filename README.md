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