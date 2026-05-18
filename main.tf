
terraform { 
  cloud { 
    hostname = "YOUR TFC OR TFE INSTANCE"
    organization = "hashicorp" 

    workspaces { 
      name = "drift-detection-main" 
      project = "Default Project" 
    } 
  } 

  required_providers {
    tfe = { }
  }
}

provider "tfe" {
  hostname = "YOUR TFC OR TFE INSTANCE"
  token    = "SEE README.MD"
}

data "tfe_organization" "hashicorp_org" {
  name = "hashicorp"
}

data "tfe_project" "theproject" {
  name = "target-project"
  organization = data.tfe_organization.hashicorp_org.name
}

resource "tfe_workspace" "theworkspace" {
  for_each     = toset(var.drift_workspace_names)
  name         = "${each.value}"
  organization = data.tfe_organization.hashicorp_org.name
  project_id   = data.tfe_project.theproject.id
}

resource "tfe_workspace_settings" "thesettings" {
  for_each     = toset(var.drift_workspace_names)
  workspace_id = tfe_workspace.theworkspace[each.value].id
  description = "The default description for ${each.value}"
  tags = { "thetag": "${each.value}" }
}
