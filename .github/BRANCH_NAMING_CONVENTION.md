# Branch naming convention

## Branch naming

> Please note for new pull requests create new branches from current `develop` branch only.

Branch name should include type of your contribution and context. Please follow next pattern for naming your branches:

```bash
feature/add-some-feature
technical/some-technical-improvements
bugfix/fix-some-bug-name
```

## Before PR actions

### Squash commits

Please squash all branch commits into the one before openning your PR from your fork. It's simple to do with the git:

```bash
git rebase -i [hash your first commit of your branch]~1
git rebase -i 6467fe36232401fa740af067cfd8ac9ec932fed2~1 # example
```

### Add commit description

Please complete your commit description folowing next pattern:

```
Technical/Add info files # should be the same name as your branch name

* Added license, changelog, contributing, code of conduct docs
* Added GitHub templates
* Updated project license link
```
