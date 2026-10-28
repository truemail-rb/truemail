# Development environment guide

## Preparing

Clone `truemail` repository:

```bash
git clone https://github.com/truemail-rb/truemail.git
cd truemail
```

Configure the latest Ruby environment:

```bash
echo 'ruby-3.1.2' > .ruby-version
cp .circleci/gemspecs/latest truemail.gemspec
```

## Installing dependencies

```bash
bundle install
bundle exec smtp_mock -s -i ~
```

## Committing

Commit your changes, excluding `.ruby-version` and `truemail.gemspec`:

```bash
git add . ':!.ruby-version' ':!truemail.gemspec'
git commit -m 'Your new awesome truemail feature'
```
