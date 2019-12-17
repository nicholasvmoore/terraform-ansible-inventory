Terraform & Ansible Stack
===================
This repository is supplemental to my [blog post](http://www.moorenix.com/2019/12/16/Terraform-Ansible/) outlining my method of integrating Terraform & Ansible.`
 
# Dependencies
| Package Name | URL |
| --- | --- |
| Terraform | [Terraform](https://www.terraform.io/)
| Terraform vSphere Provider | [Terraform Provider Documentation](https://www.terraform.io/docs/providers/vsphere/index.html) |
| Terraform Inventory | [Project Repo](https://github.com/adammck/terraform-inventory) |
| Powershell Core | [Microsoft Install Docs](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7)

## Dependency Installation
 
### MacOS Homebrew
```bash
# Instal Dependencies
brew install terraform terraform-inventory ansible
brew cask install powershell
```

### Windows WSL
```bash
mkdir bin
cd bin
wget https://releases.hashicorp.com/terraform/0.12.18/terraform_0.12.18_linux_amd64.zip
unzip terraform_0.12.18_linux_amd64.zip
rm -rf terraform_0.12.18_linux_amd64.zip
```

# Deployment Steps
```bash
terraform init
pwsh deploy.ps1
ansible-playbook -u sysop -b --private-key ~/.ssh/id_rsa -i ansible/hosts.yml ansible/deploy.yml
```

# References
[Terraform create Ansible Inventory from template](https://stackoverflow.com/questions/45489534/best-way-currently-to-create-an-ansible-inventory-from-terraform)