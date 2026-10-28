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
  echo "SUCCESS: Current gem version ($current_gem_version) was found at the top of the project changelog."
else
  echo "FAILURE: Following the \"Keep a Changelog\" convention, the current gem version ($current_gem_version) must be mentioned at the top of the project changelog."
  exit 1
fi
