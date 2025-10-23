dev-apply:
	git pull
	rm -rf .terraform/terraform.tfstate
	terraform init -backend-config=environments/dev/state.tfvars
	terraform apply -auto-approve -var-file environments/dev/main.tfvars -var token=$(token) -lock=false
	terraform state push errored.tfstate

dev-destroy:
	git pull
	rm -rf .terraform/terraform.tfstate
	terraform init -backend-config=environments/dev/state.tfvars
	terraform destroy -auto-approve -var-file environments/dev/main.tfvars -var token=$(token) -lock=false

prod-apply:
	git pull
	rm -rf .terraform/terraform.tfstate
	terraform init -backend-config=environments/prod/state.tfvars
	terraform apply -auto-approve -var-file environments/prod/main.tfvars -var token=$(token)

prod-destroy:
	git pull
	rm -rf .terraform/terraform.tfstate
	terraform init -backend-config=environments/prod/state.tfvars
	terraform destroy -auto-approve -var-file environments/prod/main.tfvars -var token=$(token)






