# Branch naming convention

## Branch naming

> Please note: for new pull requests, create new branches from the current `develop` branch only.

The branch name should include the type of your contribution and its context. Please follow this pattern when naming your branches:

```bash
feature/add-some-feature
technical/some-technical-improvements
bugfix/fix-some-bug-name
```

## Before opening a PR

### Squash commits

Please squash all branch commits into one before opening your PR from your fork. It's simple to do with git:

```bash
git rebase -i [hash of the first commit of your branch]~1
git rebase -i 6467fe36232401fa740af067cfd8ac9ec932fed2~1 # example
```

### Add commit description

Please write your commit description following this pattern:

```
Technical/Add info files # should be the same as your branch name

* Added license, changelog, contributing, code of conduct docs
* Added GitHub templates
* Updated project license link
```
