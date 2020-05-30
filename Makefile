namespace:
	@kubectl delete ns demo --ignore-not-found
	@kubectl create ns demo 

haproxy:
	@kubectl delete clusterrolebinding haproxy --ignore-not-found
	@kubectl delete clusterrole haproxy --ignore-not-found
	@kubectl delete all --namespace demo -l app=haproxy --ignore-not-found
	@kubectl delete all --namespace demo -l app=defaut-backend --ignore-not-found
	@kubectl create -f haproxy.yml
