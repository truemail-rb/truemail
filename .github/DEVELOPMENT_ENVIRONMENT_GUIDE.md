# Development environment guide

## Preparing

Clone `truemail` repository:

```bash
git clone https://github.com/truemail-rb/truemail.git
cd  truemail
```

Configure latest Ruby environment:

```bash
echo 'ruby-3.1.0' > .ruby-version
cp .circleci/gemspec_latest truemail.gemspec
```

## Installing dependencies

```bash
bundle install
bundle exec smtp_mock -s -i ~
```

## Commiting

Commit your changes excluding `.ruby-version`, `truemail.gemspec`

```bash
git add . ':!.ruby-version' ':!truemail.gemspec'
git commit -m 'Your new awesome truemail feature'
```
