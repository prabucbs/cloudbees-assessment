###### Problem statement:

Run an Nginx application using yaml file.

1. This would need a Kubernetes cluster where you can deploy your app. Any local cluster should be ok like (Minikube)
2. If at all needed you can download Nginx image and store in AWS ECR.
3. Output should be a Nginx welcome page on the browser.
4. Convert the above working YAML files into a helm chart and checkin in the GIT

###### Approach

    Due to memory crash I am unable to setup minikube in my local system. So I chose kodekloud playgrounds to complete this task. In kodekloud we can only use nodeport to expose the application as it is a learning platform.


###### Steps for running Nginx application using yaml file

1. Created nginx-deployment.yaml in home folder

2. kubectl apply -f nginx-deployment.yaml

3. kubectl expose deployment nginx-deployment --type=NodePort --port=80

4. kubectl get svc nginx-deployment

```
NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)            AGE
nginx-deployment           NodePort       10.111.109.236   `<none>`      80:30998/TCP       18m
```

So by executing above steps I was able to do a basic deployment of nginx image.

###### Steps for converting YAML files into a helm chart

Prerequisites:

Executed below command to install helm chart in kodekloud

```console
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh
```

1. Run this command in home directory "helm create nginx-chart"
2. Directory "nginx-chart" will be created and have some default files
3. Modified Chart.yaml to describe the current deployment
4. Modified values.yaml
5. Inside templates folder copied nginx-deployment.yaml and edited accordingly to accept values.yaml
6. Updated service.yaml to use nodeport
7. Deleted the deployment previously created to perfom deployment via helm charts
8. Run "helm install my-nginx nginx-chart"
9. kubectl get pods - to view the pod created via helm chart

   ```
   NAME                               READY   STATUS    RESTARTS   AGE
   nginx-deployment-544dc8b7c4-n9wml   1/1    Running    0          57m
   ```
10. kubectl get svc nginx-service

    ```
      NAME                TYPE         CLUSTER-IP     EXTERNAL-IP   PORT(S)           AGE
      nginx-service       NodePort   10.104.47.52      `<none>`     80:30462/TCP      54m
    ```
11. helm upgrade my-nginx nginx-chart -> you can use this command to reinstall or update if you are making any changes
12. helm install my-nginx nginx-chart -f values.yaml -> you can use this command if you want to specify which values file to choose for deployment
