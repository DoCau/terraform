# terraform
*Structure of this project*
THIS PROJECT WILL HAVE THESE MAIN COMPONENTS
- 1 Vpc
- 1 Public subnet
- 1 Route table
- 1 Internet gateway
- 2 EC2 (1 for Jenkins master, the other is for Jenkins worker)

*How to use this project*
**Required: GIT installed & basic knowledge
**Required: Terraform installed
**Required: AWS CLI installed

1. Clone this project to your local machine
2. Open it with VSCode (recommended)
3. Open a new terminal in VSCode
4. Run these command separately
    $terraform init
    $terraform plan
    $terraform validate
    $terrafrom apply -auto-approve
5. When the application process is completed. Go to your AWS VPC to check the resources
6. Whenever you want to remove the entire structure, run this command
    $terraform destroy -auto-approve