```
terraform init
terraform plan
terraform apply -auto-approve
```

```
ssh -i terraform-key.pem terraform@34.42.195.47
ssh -i terraform-key.pem terraform@35.193.43.170
git clone https://github.com/anakdevops/rancher-single-node.git
cd rancher-single-node
ansible-playbook install.yaml
su serverdevops
cd /home/serverdevops/
```

```
sudo nano /etc/ssh/sshd_config
PubkeyAuthentication yes
AuthorizedKeysFile %h/.ssh/authorized_keys
AllowTcpForwarding yes
sudo systemctl restart sshd
```

```
cat /home/serverdevops/.ssh/id_rsa.pub
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDvteCe3dkEPnTTs6SqxtoTmDcz4fRVkL4xwwRo18IYV8eA8Pnh5FfBXi2Vefst+ZIyHHpmXalkHQ1W1kB5US8FAyKq1ubzimNp55YrxekZaMHZI/IU4Fnk3sg/Gn4j+CJnXg4i6NuVU9IrsEPSRcPcn1G00gt8xKonic/Kx8C6iaGwq9rh+2XrL1rb5gu/i0M3GGSTmVyjTMWdUkNMJ8BTIHm7j8aZu1ZQi6O2G+cp8QrZx975bp8qoJ24SswLl/LDqWyDR4yfQM1m3gkNsCqhghF7q6WqUdk4rBFUoKJ+gTphmzM876YMuFdEZEQu+gsevzXc3VMIRxVZhbUAEL/1KsUKvfLqNdbp87/sLg+rB1zAr6nkCKJS6IvKfyciCSNp6jXP2u6arLVv9A82I4nG2GQ/dqRiWB+1pDgvvOeQwC4DO7PnXzRGLXyqaOK5kTwzo+aDNknzygA5aMRqA2Psf77zbio5PEWDBqytrUT0YOd0+6eEdNnUrfRziIyQpYCaDcJjWRiT0T+2YKUCE0eqDqWHNVcn/Zr5Y5QdytVHgPXT/5DnbZOwvr8baggpGpgrIY+2iOVxBjeA8M3DiNiDS/wkstHpuW9BXbUYF1ug9/WWiX74Q6au96Jj4nP4QnfYuDejosxbx2ZAHOCT9trv+bvfgk52a2bQuxL8p05Gvw== serverdevops@rancher-node-1" >> ~/.ssh/authorized_keys
ssh serverdevops@10.0.0.3
```

```
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
