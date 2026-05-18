# drift-detection

For testing drift detection in the local TFC/TFE instances.
- This creates a workspace `drift-detection-main` in the `hashicorp/Default Project` project.
- The [hashicorp/tfe](https://registry.terraform.io/providers/hashicorp/tfe) provider is used in that workspace to create other workspaces and workspace settings in the `hashicorp/target-project` project.
- Those workspaces and settings are resources in the `drift-detection-main` workspace.
- Changing the workspace settings (for example modifying tags) causes the `drift-detection-main` assessment to report drift.

## Setup

Stand up a local TFC or TFE instance and login as admin.

Create a `hashicorp` organization (in TFE). Create the `Default Project` and `target-project` projects in that organization.

Go to "Account Settings" and create an API token.

Clone the repo and edit main.tf:
- Set the `hostname` to your local instance, both places it appears.
- Set the `token` to the admin API token you created.

Optionally edit variables.tf:
- Change the list of workspace names, to create more or fewer workspaces in the target project.


## Create Resources

Run `terraform login` and provide the API token.

Run `terraform init` followed by `terraform apply -auto-approve`.

In your local instance's UI, verify:
- The `drift-detection-main` workspace was created in `Default Project`
- The target workspaces were created in `target-project`.
- Explorer shows the resources in `drift_detection_main`:
  - A data resource for the organization
  - A data resource for the project
  - A resource for each workspace created in `target-project`
  - A resource for each workspace-settings created in `target-project`

## Drifting

Edit the settings of the `drift-detection-main` workspace to enable health assessments, which also perform drift detection.

Manually start an assessment from the `drift-detection-main` Health>Drift page.
- It should complete and show no drift detected.
- Verify that in the Explorer workspaces view; the `drift-detection-main` workspace has 0 drifted resources.

Go to any of the workspaces created in `target-project` and edit the tags. This is drift for `drift-detection-main`!
- `drift-detection-main` has a state file which describes the `target-project` workspace-settings.
- Adding the tag makes the actual state of the workspace-settings different from the `drift-detection-main` state file.

Run another manual assessment in `drift-detection-main`.
- It will now show drift was detected.
- Verify that in the Explorer workspaces view; `drift-detection-main` has 1 drifted resource.

