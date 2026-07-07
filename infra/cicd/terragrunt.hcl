include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  github_repository = "pariveda/AI-Risk-Management-Demo"
  deploy_branch     = "main"
}
