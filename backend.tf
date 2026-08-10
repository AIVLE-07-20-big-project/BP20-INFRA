terraform {
  backend "s3" {
    bucket       = "bp20-terraform-state-652539275226-ap-northeast-2"
    key          = "bp20/prod/terraform.tfstate"
    region       = "ap-northeast-2"
    encrypt      = true
    use_lockfile = true
  }
}
