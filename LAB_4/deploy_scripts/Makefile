SHELL := /usr/bin/bash

# create ansible-vault
# set password and paste content to the file:
# <var_name>: <var_arg>
# <var_name>: <var_arg>
# ....

#ansible_vault:
#	@ansible-vault create ./inventory/group_vars/all.yml
#	@ansible-vault view   ./inventory/group_vars/all.yml
#	@ansible-vault edit   ./inventory/group_vars/all.yml

# run ansible path=./roles/k8s/tasks/main.yml # file or directory
lint:
	@ansible-lint --profile=production $(path)

################################################################################

check_inventory:
	@ansible-inventory --ask-vault-password -i inventories/dev/hosts.yml --graph
	@echo "<<<<<<<<<< ---------------------------------------------- >>>>>>>>>>"
	@ansible-inventory --ask-vault-password -i inventories/dev/hosts.yml --list

# limit via --tags, --limit
# --tags ping,get_facts
# --limit worker_1,master_0
ping:
	@ansible-playbook \
	--ask-vault-password \
	-i ./inventories/dev/hosts.yml \
	./playbooks/check_nodes.yml

# Some tags: k8s_prerequisites,k8s_check_required_ports,k8s_cri,k8s_kube,k8s_kube_init,k8s_kube_join
# usage:
# make install_k8s k8s_install_tags="tag1,tag2,..." # override tags from cli
k8s_install_tags ?=
ifneq ($(k8s_install_tags),)
	TAGS_ARG := --tags $(k8s_install_tags)
	TAGS_MSG := Selected tags: $(TAGS_ARG)
else
	TAGS_ARG :=
	TAGS_MSG := Selected tags: all
endif
install_k8s:
	@echo "$(TAGS_MSG)"
	@ansible-playbook \
	--ask-vault-password \
	-i ./inventories/dev/hosts.yml \
	$(TAGS_ARG) \
	./playbooks/kubernetes.yml

reset_k8s:
	@ansible-playbook \
	--ask-vault-password \
	-i ./inventories/dev/hosts.yml \
	--tags k8s_reset_kube \
	./playbooks/kubernetes.yml

remove_crio_and_k8s:
	@ansible-playbook \
	--ask-vault-password \
	-i ./inventories/dev/hosts.yml \
	--tags k8s_cleanup_kube_and_crio \
	./playbooks/kubernetes.yml

cleanup_k8s:
	@ansible-playbook \
	--ask-vault-password \
	-i ./inventories/dev/hosts.yml \
	--tags k8s_reset_kube,k8s_cleanup_kube_and_crio \
	./playbooks/kubernetes.yml

helm_install:
	@ansible-playbook \
	--ask-vault-password \
	-i ./inventories/dev/hosts.yml \
	--tags helm_install \
	./playbooks/helm.yml

helm_uninstall:
	@ansible-playbook \
	--ask-vault-password \
	-i ./inventories/dev/hosts.yml \
	--tags helm_uninstall \
	./playbooks/helm.yml
