terraform {
    backend "s3" {
        bucket = "itss-devops-ojt-tfstate"
        key    = "tfstate-devops-ojt-pagharion"
        region = "ap-southeast-1"
    }
}