provider "aws" {
  region     = var.region
  access_key = "AKIA3FLDZ6USSKOSCOUM"
  secret_key = "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"
}

module "vpc" {
  source = "./vpc"
  region = var.region
  project_name = var.project_name
  vpc_cidr = var.vpc_cidr
  pub_sub_1a_cidr = var.pub_sub_1a_cidr
  pub_sub_2a_cidr = var.pub_sub_2a_cidr
  alb_target_group_arn = module.elb.alb_target_group_arn
}

module "rds" {
  source = "./rds"
  vpc_id = module.vpc.vpc_id
  ec2-SG = module.vpc.SG_id
}

module "elb" {
  source = "./elb"
  project_name = module.vpc.project_name
  ec2-SG = module.vpc.SG_id
  pub_sub_1a_id = module.vpc.pub_sub_1a_id
  pub_sub_2a_id = module.vpc.pub_sub_2a_id
  vpc_id = module.vpc.vpc_id

}
 