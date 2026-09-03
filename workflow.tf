resource "port_workflow" "sync_skills_registry" {
  identifier                = "sync_port_skills_registry"
  title                     = "Sync Port Skills Registry"
  description               = "Synchronizes Markdown skill files from GitHub to the Port Skill Registry through Terraform."
  icon                      = "Github"
  category                  = "OSS Terraform"
  allow_anyone_to_view_runs = true

  node {
    identifier = "trigger"
    title      = "Sync Port Skills"

    self_serve_trigger {
      published                  = true
      action_card_button_text    = "Sync Skills"
      execute_action_button_text = "Sync"

      permissions {
        roles = var.sync_workflow_roles
      }

      user_inputs {
        order_properties = ["environment"]

        user_properties = {
          string_props = {
            environment = {
              title       = "Environment"
              description = "GitHub environment that supplies the Port and registry credentials"
              default     = "Development"
              enum        = ["Development", "Staging", "Production"]
              required    = false
            }
          }
        }
      }
    }
  }

  node {
    identifier  = "run_terraform_sync"
    title       = "Run Terraform sync"
    icon        = "Github"
    description = "Dispatches the GitHub Actions job that applies the Port Skills registry configuration."

    integration_action {
      installation_id             = var.github_ocean_installation_id
      integration_provider        = "github-ocean"
      integration_invocation_type = "dispatch_workflow"
      on_failure                  = "terminate"
      execution_properties = jsonencode({
        org                  = var.skills_registry_owner
        repo                 = var.github_sync_repository
        workflow             = var.github_sync_workflow
        reportWorkflowStatus = true
        workflowInputs = {
          environment               = "{{ .outputs[\"trigger\"].environment }}"
          port_workflow_node_run_id = "{{ .workflowNodeRun.identifier }}"
        }
      })
    }
  }

  connections {
    source_identifier = "trigger"
    target_identifier = "run_terraform_sync"
  }
}
