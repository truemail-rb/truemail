#!/bin/sh
set -e

changelog=$(if [ "$1" = "" ]; then echo "CHANGELOG.md"; else echo "$1"; fi)

get_current_gem_version() {
  ruby -r rubygems -e "puts Gem::Specification::load('$(ls -- *.gemspec)').version"
}

latest_changelog_tag() {
  grep -Po "(?<=\#\# \[)[0-9]+\.[0-9]+\.[0-9]+?(?=\])" "$changelog" | head -n 1
}

current_gem_version="$(get_current_gem_version)"

if [ "$current_gem_version" = "$(latest_changelog_tag)" ]
then
  echo "SUCCESS: Current gem version ($current_gem_version) has been found on the top of project changelog."
else
  echo "FAILURE: Following to \"Keep a Changelog\" convention current gem version ($current_gem_version) must be mentioned on the top of project changelog."
  exit 1
fi
