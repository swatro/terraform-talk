## How to deploy to AWS

* Setup the correct environment variable:
```
export AWS_ACCESS_KEY_ID={key}
export AWS_SECRET_ACCESS_KEY={key}
```

* Validate that S3 bucket exists. Bucket is called `watro-terraform-aws-state`

* `Terraform plan` to check what will be deployed

* `Terraform apply` to deploy 
