.PHONY: start-prod stop restart logs elastic
PROJECTS = pub-01 sub-01
INFRAS = rabbitmq-topics

pre-dev:
	for dir in $(PROJECTS); do \
		cd ./$$dir; \
		pwd ; \
		npm i; \
		cd ..; \
	done

start-all:
	for dir in $(PROJECTS); do \
		docker compose -f docker-compose.yml -f docker-compose.depends.yml -f docker-compose.${e}.yml up $$dir --build -d ; \
	done

compose-up:
	docker compose -f docker-compose.yml -f docker-compose.depends.yml -f docker-compose.${e}.yml up ${s} --build -d

migration-up:
	docker compose exec drivers-account-service npx typeorm migration:run -d dist/config/typeOrm.config.js
	docker compose exec api-merchants npx typeorm migration:run -d dist/config/typeOrm.config.js
	docker compose exec api-vouchers npx typeorm migration:run -d dist/config/typeOrm.config.js

#	docker compose exec drivers-account-service npm run migration:up
#	docker compose exec api-merchants npm run migration:up
#	docker compose exec api-vouchers npm run migration:up


down:
	docker compose down --volumes

clean:
	rm -rf **/node_modules && rm -rf **/dist && rm -rf **/log

log:
	docker compose logs -f $(s)

k8s-build:
	docker buildx build --platform linux/amd64 --push -t hub.10z.one/$(s):${v} ./$(s)

k8s-build-all:
	for dir in $(PROJECTS); do \
		docker buildx build --platform linux/amd64 --push -t hub.10z.one/$$dir:${v} ./$$dir ; \
	done

docker-build:
	docker buildx build --platform linux/amd64 --push -t hub.10z.one/$(s):${v} ./$(s)

k8s-restart:
	kubectl rollout restart deployment $(s)

k8s-apply:
	kubectl apply -f k8s/$(s)-deployment.yaml


k8s-logs:
	kubectl logs -f `kubectl get pods | grep $(s) | awk '{print $$1}' | head -n 1`

prometheus:
	kubectl port-forward svc/kube-prometheus-stack-prometheus 9090:9090 -n kube-prometheus-stack

grafana:
	kubectl port-forward svc/kube-prometheus-stack-grafana 3100:80 -n kube-prometheus-stack

# Deploy với image version mới nhất. Đầu vào là tên service (s) và version (v)
k8s-deploy:
	docker buildx build --platform linux/amd64 --push -t hub.10z.one/$(s):$(v) ./$(s) ; \
	kubectl set image deployment/$(s) $(s)=hub.10z.one/$(s):$(v) ; \
	kubectl annotate deployment/$(s) kubernetes.io/change-cause="update image version to $(v)" ; \

# Deploy các service cụ thể (khi merge vào main) với version xác định. Sử dụng cho CI/CD. Không cần truyền tham số.
k8s-ci:
	for dir in $(CURRENT_DEPLOYS); do \
		docker buildx build --platform linux/amd64 --push -t hub.10z.one/$$dir:latest -t hub.10z.one/$$dir:$(CURRENT_VERSION) ./$$dir ; \
		kubectl set image deployment/$$dir $$dir=hub.10z.one/$$dir:$(CURRENT_VERSION) ; \
		kubectl annotate deployment/$$dir kubernetes.io/change-cause="update image version to $(CURRENT_VERSION)" ; \
	done

# Xem lịch sử deploy của service (s)
k8s-histories:
	kubectl rollout history deployment/$(s)

# Khôi phục lại version (r) của service (s)
k8s-rollback:
	kubectl rollout undo deployment/$(s) --to-revision=$(r)

k8s-dashboard:
	export POD_NAME=$(kubectl get pods -n kubernetes-dashboard -l "app.kubernetes.io/name=kubernetes-dashboard,app.kubernetes.io/instance=kubernetes-dashboard" -o jsonpath="{.items[0].metadata.name}") ; \
	kubectl -n kubernetes-dashboard port-forward $POD_NAME 8443:8443 ; \

build-staging:
	for dir in $(PROJECTS); do \
		docker buildx build --platform linux/amd64 --push -t hub.10z.one/$$dir:staging ./$$dir ; \
	done

build-service-staging:
	docker buildx build --platform linux/amd64 --push -t hub.10z.one/$(s):staging ./$(s)
