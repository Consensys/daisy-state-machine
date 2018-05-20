#!/bin/bash
echo "Enter an address or press enter for no address"
read ADDRESS

if [ $ADDRESS ]; then
  echo "Enter password to decrypt wallet"
  stty_orig=`stty -g` # save original terminal setting.
  stty -echo          # turn-off echoing.
  read PASSWORD         # read the password
  stty $stty_orig     # restore terminal setting.

  export ADDRESS
  export PASSWORD
fi

$@
