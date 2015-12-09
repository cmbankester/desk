#!/bin/bash

# Run automated tests to ensure desk is behaving as expected

ensure() {
  if [ $1 -ne 0 ]; then
    echo "Failed: $2"
    exit 1
  fi
}

ensure_not(){
  if [ $1 -eq 0 ]; then
    echo "Failed: $2"
    exit 1
  fi
}

desk | grep "No desk activated." >/dev/null
ensure $? "Desk without desk activated fails."
desk --version | grep "◲  desk " >/dev/null
ensure $? "Desk version fails."

HELP=$(desk help)
ensure $? "Desk help fails."
echo "$HELP" | grep 'desk init' >/dev/null
ensure $? "Desk help doesn't contain init"
echo "$HELP" | grep 'desk (list|ls)' >/dev/null
ensure $? "Desk help doesn't contain list"
echo "$HELP" | grep 'desk (.|go)' >/dev/null
ensure $? "Desk help doesn't contain go"
echo "$HELP" | grep 'desk help' >/dev/null
ensure $? "Desk help doesn't contain help"
echo "$HELP" | grep 'desk version' >/dev/null
ensure $? "Desk help doesn't contain version"

desk init <<ANSWER


ANSWER

rm -rf "$HOME/.desk/desks"
ln -s "$HOME/examples" "$HOME/.desk/desks"

## `desk list`

# without options
LIST=$(desk list)
echo "$LIST" | grep "desk - the desk I use to work on desk :)" >/dev/null
ensure $? "Desk list missing desk (with symlink)"
echo "$LIST" | grep "python_project - desk for working on a Python project" >/dev/null
ensure $? "Desk list missing python_project (with symlink)"
echo "$LIST" | grep "terraform - desk for doing work on a terraform-based repository" >/dev/null
ensure $? "Desk list missing terraform (with symlink)"

# --only-names
LIST=$(desk list --only-names)
echo "$LIST" | grep "the desk I use to work on desk :)" >/dev/null
ensure_not $? "Desk list --only-names contains 'desk' description (with symlink)"
echo "$LIST" | grep -e '^desk$' >/dev/null
ensure $? "Desk list --only-names missing 'desk' (with symlink)"

# --only-descriptions
LIST=$(desk list --only-descriptions)
echo "$LIST" | grep "python_project" >/dev/null
ensure_not $? "Desk list --only-descriptions contains 'python_project' name (with symlink)"
echo "$LIST" | grep -e '^desk for working on a Python project$' >/dev/null
ensure $? "Desk list --only-descriptions missing 'python_project' description (with symlink)"

# --show-header
echo "$(desk list --show-header)" | grep "NAME - DESCRIPTION" >/dev/null
ensure $? "Desk list --show-header option did not add the header (with symlink)"
echo "$(desk list --show-header --only-names)" | grep -e "^NAME$" >/dev/null
ensure $? "Desk list --show-header option did not add the header when used with the --only-names option (with symlink)"
echo "$(desk list --show-header --only-descriptions)" | grep -e "^DESCRIPTION$" >/dev/null
ensure $? "Desk list --show-header option did not add the header when used with the --only-descriptions option (with symlink)"

# --delim
echo "$(desk list --delim 'foobar')" | grep "deskfoobarthe desk I use to work on desk :)" >/dev/null
ensure $? "Desk list --delim option did not delimit 'desk' name/description (with symlink)"
echo "$(desk list --delim 'foobar' --show-header)" | grep "NAMEfoobarDESCRIPTION" >/dev/null
ensure $? "Desk list --delim option did not delimit header when used with the --show-header option (with symlink)"

# --auto-align
LIST=$(desk list --auto-align)
echo "$LIST" | grep "desk            the desk I use to work on desk :)" >/dev/null
ensure $? "Desk list did not align 'desk' with the --auto-align option (with symlink)"
echo "$LIST" | grep "python_project  desk for working on a Python project" >/dev/null
ensure $? "Desk list did not align 'python_project' with the --auto-align option (with symlink)"
echo "$LIST" | grep "terraform       desk for doing work on a terraform-based repository" >/dev/null
ensure $? "Desk list did not align 'terraform' with the --auto-align option (with symlink)"
LIST=$(desk list --auto-align --show-header)
echo "$LIST" | grep "NAME            DESCRIPTION" >/dev/null
ensure $? "Desk list did not align header with the --auto-align and --show-header options (with symlink)"

# DESK_DESKS_DIR=...
rm -rf "$HOME/.desk/desks"
LIST=$(DESK_DESKS_DIR=$HOME/examples desk list)
echo "$LIST" | grep "desk - the desk I use to work on desk :)" >/dev/null
ensure $? "Desk list missing desk (with DESK_DESKS_DIR)"
echo "$LIST" | grep "python_project - desk for working on a Python project" >/dev/null
ensure $? "Desk list missing python_project (with DESK_DESKS_DIR)"
echo "$LIST" | grep "terraform - desk for doing work on a terraform-based repository" >/dev/null
ensure $? "Desk list missing terraform (with DESK_DESKS_DIR)"

ln -s "$HOME/examples" "$HOME/.desk/desks"

mkdir ~/terraform-repo

CURRENT=$(DESK_ENV=$HOME/.desk/desks/terraform.sh desk)
echo "$CURRENT" | grep 'set_aws_env - Set up AWS env variables: <key id> <secret>' >/dev/null
ensure $? "Desk current terraform missing set_aws_env"
echo "$CURRENT" | grep 'plan - Run `terraform plan` with proper AWS var config' >/dev/null
ensure $? "Desk current terraform missing plan"
echo "$CURRENT" | grep 'apply - Run `terraform apply` with proper AWS var config' >/dev/null
ensure $? "Desk current terraform missing apply"
echo "$CURRENT" | grep 'config - Set up terraform config: <config_key>' >/dev/null
ensure $? "Desk current terraform missing config"

echo "tests pass."
