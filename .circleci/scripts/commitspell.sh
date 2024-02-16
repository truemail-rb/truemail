#!/bin/sh
set -e

configuration=$(if [ "$2" = "" ]; then echo "$2"; else echo " $1 $2"; fi)
latest_commit=$(git rev-parse HEAD)

spellcheck_info() {
  echo "Checking the spelling of the latest commit ($latest_commit) message..."
}

compose_cspell_command() {
  echo "cspell-cli lint stdin$configuration"
}

cspell="$(compose_cspell_command)"

spellcheck_latest_commit() {
  git log -1 --pretty=%B | $cspell
}

spellcheck_info
spellcheck_latest_commit
