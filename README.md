# terrabash
Tools for run terraform easier using bash script

# REQUIREMENTS
## 1. Directory
- Terraform Working Directory (should be cloned from repository).

	example: [terraform-aws-infrastructures-example][terraform]
- Terrabash (clone this repo)

## 2. File
- Terraform should be stored to file named `main.tf`

## 3. State Location
- AWS S3
	```
	terraform {
		backend "s3" {
			bucket = "<bucket_name>"
			key    = "<path_to_tf_file>/states.tfstate"
			region = "<region>"
		}
	}
	```
- Google Cloud Storage (GCS)
	```
	terraform {
		backend "gcs" {
			bucket = "<bucket_name>"
			prefix = "<path_to_tf_file>/"
		}
	}
	```

### *NOTE* :
**`bucket`** = Bucket name to store terraform state

eg:
```
bucket = "sanimuhlison-terraform-states"
```
**`key`** = Path of `main.tf` (AWS S3)

eg:
```
key    = "project-abc/iam/users/sanimuhlison/states.tfstate"
```

**`prefix`** = Path of `main.tf` (GCS)

eg:
```
prefix = "project-abc/iam/users/sanimuhlison/"
```
**`region`** = Region on AWS

eg:
```
region = "ap-southeast-1"
```


## 4. ENVIRONMENT VARIABLE
- Create Environment Variable using `.env` file with value like following sample:
	```
	export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
	export TF_DIR="<YOUR TERRAFORM LOCATION>"
	export TF_RUN="<YOUR TERRABASH LOCATION>"
	```
- run `source .env`



### *NOTE* : 
**`TF_PLUGIN_CACHE_DIR`** = Path of Plugin Cache Directory
	
**`TF_DIR`** = Path of terraform working directory. 

eg: 
``` 
/Users/sanimuhlison/terraform-aws-infrastructures-example/
```
**`TF_RUN`** = Path of terrabash directory

eg:
```
/Users/sanimuhlison/terrabash/
```

This Environment variable will be used by terrabash to know where is your *Terraform Working Directory* and *Terrabash Direcory* it self. If there's any changes on your Terraform Working Directory, terrabash will check it and do run terraform for it.

## 5. AWS or GCP Access
- Make sure you can access AWS or GCP Resource via SDK, so you can store your terraform state and create resources via terraform.

# How to Use?
- Go to your *Terraform Working Directory*, create `sample-directory/main.tf` and write your terraform code. Or you can clone [terraform-aws-infrastructures-example][terraform] for sample.
- Once finished, go to terrabash directory by type `cd $TF_RUN`
- Then run **terrabash command** (see command below)

# Terrabash Command
## Pre Commit
```
bash run-pre-commit.sh init
bash run-pre-commit.sh init --simple-view
bash run-pre-commit.sh plan
bash run-pre-commit.sh plan --simple-view
bash run-pre-commit.sh apply
bash run-pre-commit.sh apply --simple-view
```

This command used to execute terraform before terraform code committed


## Post Commit
```
bash run-pre-commit.sh init
bash run-pre-commit.sh init --simple-view
bash run-pre-commit.sh plan
bash run-pre-commit.sh plan --simple-view
bash run-pre-commit.sh apply
bash run-pre-commit.sh apply --simple-view
```
This command used to execute terraform after terraform code committed

# Input
Once you run command above, you will be ask to input array number that you want to execute. 
Option:
- `all`

	Will execute all files
- single array number, eg: `4`

	Will execute file on array 4
- range array number, eg: `1-4`
	
	Will execute file on array between 1 to 4

# Example
```
$ bash run-pre-commit.sh init
-----------------------------------------
LIST OF DIRECTORY [ TERRAFORM INIT ]:
-----------------------------------------
[1]-project-abc/iam/users/sanimuhlison/
[3]-project-xyz/iam/users/muhlisonsani/
-----------------------------------------

-----------------------------------------
Choose array number to be INIT: all
-----------------------------------------
GO TO >> [1]-project-abc/iam/users/sanimuhlison/
-----------------------------------------
STATE Location:  project-abc/iam/users/sanimuhlison/
STATE Location:  OK..........................................................[OK]
/Users/sanimuhlison/terraform-aws-infrastructures-example/project-abc/iam/users/sanimuhlison

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 3.0"...
- Using hashicorp/aws v3.50.0 from the shared cache directory

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

-----------------------------------------
GO TO >> [3]-project-xyz/iam/users/muhlisonsani/
-----------------------------------------
STATE Location:  project-xyz/iam/users/muhlisonsani/
STATE Location:  OK..........................................................[OK]
/Users/sanimuhlison/terraform-aws-infrastructures-example/project-xyz/iam/users/muhlisonsani

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 3.0"...
- Using hashicorp/aws v3.50.0 from the shared cache directory

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

## Other Feature
- Support pre-commit

[terrabash]: https://github.com/sanimuhlison/terrabash
[terraform]: https://github.com/sanimuhlison/terraform-aws-infrastructures-example
