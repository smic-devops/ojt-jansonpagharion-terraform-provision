@Library('devops-jenkins-shared-library@ojt-cloud') _

def gitbranch = "${env.BRANCH_NAME}"
def project_name = "ojt-jansonpagharion-terraform-provision"


ojtPagharionTerraform(
    gitbranch : "${gitbranch}",
    project_name: "${project_name}"
)
