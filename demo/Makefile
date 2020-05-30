dev:
	@iex -S mix phx.server

docker:
	@docker build -t demo .

namespace:
	@kubectl delete ns demo --ignore-not-found
	@kubectl create ns demo 

haproxy:
	@kubectl delete clusterrolebinding haproxy --ignore-not-found
	@kubectl delete clusterrole haproxy --ignore-not-found
	@kubectl delete all --namespace demo -l app=haproxy --ignore-not-found
	@kubectl delete all --namespace demo -l app=defaut-backend --ignore-not-found
	@kubectl create -f k8s/haproxy.yml

demo:
	@kubectl delete ingress demo --namespace demo --ignore-not-found
	@kubectl delete all --namespace demo -l app=demo --ignore-not-found
	@kubectl create -f k8s/demo.yml

scale:
	@kubectl scale deployment demo -n demo --replicas=$(replicas)

pods:
	@kubectl get pods -n demo

logs:
	@kubectl logs -n demo -f `kubectl get pods -n demo | grep demo | head -n 1 | cut -d " " -f 1`

sh:
	@kubectl exec -it -n demo `kubectl get pods -n demo | grep demo | cut -d " " -f 1` -- sh
