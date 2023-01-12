#!/bin/sh
set -e

GH_CLI_RELEASES_URL="https://github.com/cli/cli/releases"
FILE_NAME="gh"
BUILD_ARCHITECTURE="linux_amd64.deb"
DELIMETER="_"
PACKAGE_FILE="$FILE_NAME$DELIMETER$BUILD_ARCHITECTURE"

gh_cli_latest_release() {
  curl -sL -o /dev/null -w '%{url_effective}' "$GH_CLI_RELEASES_URL/latest" | rev | cut -f 1 -d '/'| rev
}

download_gh_cli() {
  test -z "$VERSION" && VERSION="$(gh_cli_latest_release)"
  test -z "$VERSION" && {
    echo "Unable to get GitHub CLI release." >&2
    exit 1
  }
  curl -s -L -o "$PACKAGE_FILE" "$GH_CLI_RELEASES_URL/download/$VERSION/$FILE_NAME$DELIMETER$(printf '%s' "$VERSION" | cut -c 2-100)$DELIMETER$BUILD_ARCHITECTURE"
}

install_gh_cli() {
  sudo dpkg -i "$PACKAGE_FILE"
  rm "$PACKAGE_FILE"
}

get_release_candidate_version() {
  ruby -r rubygems -e "puts Gem::Specification::load('$(ls -- *.gemspec)').version"
}

release_candidate_tag="v$(get_release_candidate_version)"

is_an_existing_github_release() {
  git fetch origin "refs/tags/$release_candidate_tag" >/dev/null 2>&1
}

release_to_rubygems() {
  echo "Setting RubyGems publisher credentials..."
  ./.circleci/scripts/set_publisher_credentials.sh
  echo "Preparation for release..."
  git config --global user.email "${PUBLISHER_EMAIL}"
  git config --global user.name "${PUBLISHER_NAME}"
  git stash
  gem install yard gem-ctags
  bundle install
  echo "Publishing new gem release to RubyGems..."
  rake release
}

release_to_github() {
  echo "Downloading and installing latest gh cli..."
  download_gh_cli
  install_gh_cli
  echo "Publishing new release notes to GitHub..."
  gh release create "$release_candidate_tag" --generate-notes
}

update_develop_branch() {
  echo "Updating develop branch with new release tag..."
  git checkout develop
  git merge "$release_candidate_tag" --ff --no-edit
  git push origin develop
}

if is_an_existing_github_release
then echo "Tag $release_candidate_tag already exists on GitHub. Skipping releasing flow..."
else release_to_rubygems; release_to_github; update_develop_branch
fi
