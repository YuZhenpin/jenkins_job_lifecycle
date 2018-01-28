NETWORK=ci-network

create-volume:
	mkdir -p \
	$(PWD)/mysql \
	$(PWD)/jenkins_home \
	$(PWD)/gitlab/config \
	$(PWD)/gitlab/data \
	$(PWD)/gitlab/logs

create-network:
	docker network create \
	--driver=overlay \
	--attachable \
	$(NETWORK)

rm-network:
	docker network rm $(NETWORK)

create-mysql:
	docker service create \
	--name mysql \
	--publish 3306:3306 \
	--env MYSQL_ROOT_PASSWORD=admin \
	--mount type=bind,source=$(PWD)/mysql,destination=/var/lib/mysql \
	--network $(NETWORK) \
	mysql

create-jenkins:
	docker service create \
	--name jenkins \
	--publish 8080:8080 \
	--publish 50000:50000 \
	--mount type=bind,source=$(PWD)/jenkins_home,destination=/var/jenkins_home \
	--network $(NETWORK) \
	pin/jenkins

create-gitlab:
	docker service create \
	--name gitlab \
	--publish 10443:443 \
	--publish 1080:80 \
	--publish 1022:22 \
	--mount type=bind,source=$(PWD)/gitlab/config,destination=/etc/gitlab \
	--mount type=bind,source=$(PWD)/gitlab/logs,destination=/var/log/gitlab \
	--mount type=bind,source=$(PWD)/gitlab/data,destination=/var/opt/gitlab \
	--network $(NETWORK) \
	gitlab/gitlab-ce:latest

create-myadmin:
	docker service create \
	--name myadmin \
	--publish 13306:80 \
	--env PMA_ARBITRARY=1 \
	--env MYSQL_ROOT_PASSWORD=admin \
	--network $(NETWORK) \
	phpmyadmin/phpmyadmin

rm-mysql:
	docker service rm mysql

rm-jenkins:
	docker service rm jenkins

rm-myadmin:
	docker service rm myadmin

rm-gitlab:
	docker service rm gitlab

create: create-mysql create-jenkins

rm: rm-mysql rm-jenkins
