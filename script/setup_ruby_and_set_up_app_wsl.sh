#!/usr/bin/env zsh
# you may need to adjust zsh to whatever shell you use bash etc.
echo "Installing package manage mise and dependencies for ruby, node and yarn"
curl https://mise.run | sh
eval "$(~/.local/bin/mise activate zsh)" # again adjust to your shell
mise install ruby@3.4.2
mise install node@20
mise install yarn@latest
mise use -g ruby node yarn

echo "Installing rails"
gem install rails

echo "Installing bundler"
gem install bundler

echo "Installing postgresql client"
apt-get update && apt-get install -y postgresql-client

echo "Cloning the repository"
git clone https://github.com/shenefelt-org/pkmnditto.git

echo "Changing directory to pkmnditto"
cd pkmnditto

echo "Installing gems"
bundle install

echo "Installing node modules"
yarn install

echo "Precompiling assets"
RAILS_ENV=production bundle exec rake assets:precompile

echo "Pkmnditto build complete."

