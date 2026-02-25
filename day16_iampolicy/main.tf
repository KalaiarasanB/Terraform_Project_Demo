# Get AWS Account ID
data "aws_caller_identity" "current" {} 

# Output the account ID
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

# # Read users from CSV
# locals {
#   users = csvdecode(file("users.csv"))
# }

# Output user names
output "user_names" {
  value = [for user in local.users : "${user.first_name} ${user.last_name}"]
}

# Create IAM users
resource "aws_iam_user" "users" {
  for_each = { for user in local.users : user.first_name => user }

  name = lower("${substr(each.value.first_name, 0, 1)}${each.value.last_name}") # FIX 2: Removed space between first initial and last name
  path = "/users/"

  tags = {
    "DisplayName" = "${each.value.first_name} ${each.value.last_name}"
    "Department"  = each.value.department    
    "JobTitle"    = each.value.job_title
  }
}

# Create IAM user login profiles (password)
resource "aws_iam_user_login_profile" "users" { # FIX 3: Correct resource name
  for_each = aws_iam_user.users

  user                    = each.value.name
  password_reset_required = true
  password_length         = 16 # Good practice: specify a length so ignore_changes makes sense

  lifecycle {
    ignore_changes = [
      password_length,
      password_reset_required,
      pgp_key # Standard inclusion for login_profile lifecycle
    ]
  }
}

# Output user passwords status
output "user_passwords" {
  value = {
    for user, profile in aws_iam_user_login_profile.users : # FIX 3 applied here too
    user => "Password created - user must reset on first login"
  }
  sensitive = true
}

