#!/bin/bash

# Правим конфигурационный файл GitLab
sudo sed -i "s|external_url 'http://localhost'|external_url 'http://158.160.170.158'|g" /etc/gitlab/gitlab.rb
sudo sed -i "s|# gitlab_rails['initial_root_password'] = 'password'|gitlab_rails['initial_root_password'] = 'toortoor'|g" /etc/gitlab/gitlab.rb
sudo sed -i "s|# gitlab_rails['initial_shared_runners_registration_token'] = 'token'|gitlab_rails['initial_shared_runners_registration_token'] = 'toortoor'|g" /etc/gitlab/gitlab.rb
sudo sed -i "s|# gitlab_rails['store_initial_root_password'] = nil|gitlab_rails['store_initial_root_password'] = true|g" /etc/gitlab/gitlab.rb
sudo sed -i "s|# nginx['enable'] = false|nginx['enable'] = true|g" /etc/gitlab/gitlab.rb
sudo sed -i "s|# nginx['client_max_body_size'] = '250m'|nginx['client_max_body_size'] = '250m'|g" /etc/gitlab/gitlab.rb
sudo sed -i "s|# nginx['redirect_http_to_https'] = false|nginx['redirect_http_to_https'] = false|g" /etc/gitlab/gitlab.rb
sudo sed -i "s|# nginx['redirect_http_to_https_port'] = 80|nginx['redirect_http_to_https_port'] = 80|g" /etc/gitlab/gitlab.rb

# Перезапускаем GitLab для применения изменений
sudo gitlab-ctl reconfigure > gitlab.log 2>&1

# Проверяем статус GitLab
systemctl status gitlab-runsvdir.service
sudo gitlab-ctl status
