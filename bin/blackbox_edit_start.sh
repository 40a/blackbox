#!/bin/bash

#
# blackbox_edit_start.sh -- Decrypt a file for editing.
#

source bin/blackbox_common.sh
set -e

fail_if_bad_environment

for param in """$@""" ; do
  unencrypted_file=$(get_unencrypted_filename "$param")
  encrypted_file=$(get_encrypted_filename "$param")
  echo ========== PLAINFILE "$unencrypted_file"

  fail_if_not_on_cryptlist "$unencrypted_file"
  fail_if_not_exists "$encrypted_file" "This should not happen."
  if [[ ! -s "$unencrypted_file" ]]; then
    rm -f "$unencrypted_file"
  fi
  if [[ -f "$unencrypted_file" ]]; then
    echo SKIPPING: "$1" "Will not overwrite non-empty files."
    continue
  fi

  prepare_keychain
  decrypt_file "$encrypted_file" "$unencrypted_file"
done
