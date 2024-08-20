```
terraform init
terraform plan
terraform apply -auto-approve
```

```
ssh -i terraform-key.pem terraform@34.42.195.47
ssh -i terraform-key.pem terraform@35.193.43.170
sudo su
git clone https://github.com/anakdevops/terraform_gcp_rancher_multinode.git
cd terraform_gcp_rancher_multinode
ansible-playbook install.yaml
cat /home/serverdevops/cluster.yml
```

```
sudo nano /etc/ssh/sshd_config
PubkeyAuthentication yes
AuthorizedKeysFile      .ssh/authorized_keys .ssh/authorized_keys2
AllowTcpForwarding yes
sudo systemctl restart sshd
```

```
su serverdevops
cat /home/serverdevops/.ssh/id_rsa.pub
echo "{{COPY SSH KEY}}" >> ~/.ssh/authorized_keys
ssh serverdevops@10.0.0.3
```

```
su serverdevops
cd /home/serverdevops/
cat /home/serverdevops/cluster.yml
rke up --config cluster.yml
INFO[0176] Finished building Kubernetes cluster successfully
export KUBECONFIG=$HOME/kube_config_cluster.yml
kubectl get nodes
```

```
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
kubectl create namespace cattle-system
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.13.2
helm install rancher rancher-latest/rancher --namespace cattle-system --set hostname=rancher.anakdevops.local
kubectl -n cattle-system get deploy rancher
kubectl scale --replicas=1 deployment rancher -n cattle-system
kubectl -n cattle-system get deploy rancher -w
```


```
terraform destroy -auto-approve
```
