#!/usr/bin/env bash

#
# blackbox_edit_end.sh -- Re-encrypt file after edits.
#

source blackbox_common.sh
set -e

fail_if_bad_environment

if [[ -z $GPG_AGENT_INFO ]]; then
  echo 'WARNING: You probably want to run gpg-agent as'
  echo 'you will be asked for your passphrase many times.'
  echo 'Example: $ eval $(gpg-agent --daemon)'
  read -p 'Press CTRL-C now to stop. ENTER to continue: '
fi

disclose_admins

echo '========== ENCRYPTED FILES TO BE RE-ENCRYPTED:'
awk <"$BB_FILES" '{ print "    " $1 ".gpg" }'

echo '========== FILES IN THE WAY:'
need_warning=false
for i in $(<$BB_FILES) ; do
  unencrypted_file=$(get_unencrypted_filename "$i")
  encrypted_file=$(get_encrypted_filename "$i")
  if [[ -f "$unencrypted_file" ]]; then
    need_warning=true
    echo "    $unencrypted_file"
  fi
done
if $need_warning ; then
  echo
  echo 'WARNING: This will overwrite any unencrypted files laying about.'
  read -p 'Press CTRL-C now to stop. ENTER to continue: '
else
  echo 'All OK.'
fi

echo '========== RE-ENCRYPTING FILES:'
for i in $(<$BB_FILES) ; do
  unencrypted_file=$(get_unencrypted_filename "$i")
  encrypted_file=$(get_encrypted_filename "$i")
  echo ========== PROCESSING "$unencrypted_file"
  fail_if_not_on_cryptlist "$unencrypted_file"
  decrypt_file_overwrite "$encrypted_file" "$unencrypted_file"
  encrypt_file "$unencrypted_file" "$encrypted_file"
  shred_file "$unencrypted_file"
done

fail_if_keychain_has_secrets

echo '========== COMMITING TO HG:'
hg commit -m'Re-encrypted keys' $(awk <$BB_FILES '{ print $1 ".gpg" }' )

echo '========== DONE.'
echo 'Likely next step:'
echo '    hg push'
