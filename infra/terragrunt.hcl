locals {
  git_dir = run_cmd("git", "rev-parse", "--show-toplevel")

  project_name = reverse(split("/", local.git_dir))[0]

  tfstate_kv_path = substr(get_terragrunt_dir(), length(local.git_dir) - length(local.project_name), -1)
}

inputs = {}

remote_state {
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  backend = "http"
  config = {
    username       = get_env("TF_BACKEND_USERNAME")
    password       = get_env("TF_BACKEND_PASSWORD")
    address        = "https://tf.kaipov.com/${local.tfstate_kv_path}"
    lock_address   = "https://tf.kaipov.com/${local.tfstate_kv_path}"
    unlock_address = "https://tf.kaipov.com/${local.tfstate_kv_path}"
  }
}

retry_max_attempts       = 3
retry_sleep_interval_sec = 10
