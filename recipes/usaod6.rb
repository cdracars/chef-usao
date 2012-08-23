#
# Cookbook Name:: usao
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#  bash "clone-the-usao-main-repo" do
#    code <<-EOH
#        cd ~/
#        if [ -d "/root/usao-main" ];
#            then
#                cd usao-main; git pull origin master;
#                else git clone git@bitbucket.org:cdracars/usao-main.git;
#            fi;
#    EOH
#  end

  bash "create-drupal6-directory" do
    code <<-EOH
      cd /var
      if [ -d "/var/www/drupal6" ];
        then
            echo "file made alreay";
        else
            mkdir www/drupal6;
        fi;
    EOH
  end

  template "/var/www/drupal6/usaod6.make" do
    source "usaod6.make"
    owner "root"
    group "www-data"
    mode 0440
  end

  template "/var/www/drupal6/usaod6core.make" do
    source "usaod6core.make"
    owner "root"
    group "www-data"
    mode 0440
  end

  execute "drush-make-pressflow-6-core" do
      cwd "/var/www/drupal6"
      command "drush make -y usaod6core.make"
      not_if do
        File.exists?("/var/www/drupal6/index.php")
      end
  end

  bash "import-git-repo-and-change-permissions" do
    code <<-EOH
        if [ -d "www/drupal6/sites/d6mig.usao.dev" ];
            then
                echo "changes made previosly";
            else
                cd /var
#                rm -rf www/drupal6/sites/*
#                cp -r ~/usao-main/* www/drupal6/sites/.
#                mv www/drupal6/sites/usao.edu www/drupal6/sites/d6mig.usao.dev
                mkdir www/drupal6/sites/d6mig.usao.dev
                mkdir www/drupal6/sites/d6mig.usao.dev/files
                find drupal6 -type d -exec chmod g+rwxs {} \;
                chgrp -R www-data www/drupal6
                chmod -R g+rw www/drupal6
            fi;
    EOH
  end

  execute "drush-make-modules and sites" do
      cwd "/var/www/drupal6/sites/d6mig.usao.dev"
      command "drush make -y --no-core --working-copy --contrib-destination=. /var/www/drupal6/usaod6.make"
      not_if do
        File.exists?("/var/www/drupal6/sites/d6mig.usao.dev/modules")
      end
  end

  # Add an admin user to mysql
  execute "add-mysql-admin-user" do
    command "/usr/bin/mysql -u root -p#{node[:mysql][:server_root_password]} -e \"" +
        "GRANT ALL PRIVILEGES ON *.* TO 'usao'@'localhost' IDENTIFIED BY '#{node[:mysql][:server_root_password]}' WITH GRANT OPTION;" +
        "GRANT ALL PRIVILEGES ON *.* TO 'usao'@'%' IDENTIFIED BY '#{node[:mysql][:server_root_password]}' WITH GRANT OPTION;\" " +
        "mysql"
    action :run
  end

  # create a drupal db
  execute "add-drupal-db" do
    command "/usr/bin/mysql -u root -p#{node[:mysql][:server_root_password]} -e \"" +
        "CREATE DATABASE usaoedu;\""
    action :run
    ignore_failure true
  end

  bash "create-drupal-6-database" do
    code <<-EOH
      if [ /mnt/usao_backups/mysqldumps/current/usaoedu.sql.gz -nt ~/usaoedu.sql ];
        then
          #zcat /mnt/usao_backups/mysqldumps/current/usaoedu.sql.gz > ~/usaoedu.sql;
          zcat /mnt/usao_backups/mysqldumps/current/usaoedu.sql.gz | sed '1i \
          SET AUTOCOMMIT = 0; \
          SET FOREIGN_KEY_CHECKS=0;' | sed '$a \
          SET FOREIGN_KEY_CHECKS = 1; \
          COMMIT; \
          SET AUTOCOMMIT = 1;' > ~/usaoedu.sql
          mysql -u root -p#{node[:mysql][:server_root_password]} usaoedu < ~/usaoedu.sql;
        else
          echo "File 1 is older than file 2";
      fi;
  EOH
  end

  template "/var/www/drupal6/sites/d6mig.usao.dev/settings.php" do
    source "d6settings.php.erb"
    mode 0440
    owner "vagrant"
    group "www-data"
    notifies :restart, resources("service[varnish]"), :delayed
  end

  execute "enable-features-and-custom-modules" do
      cwd "/var/www/drupal6/sites/d6mig.usao.dev"
      command "drush en -y usao_directory usao_sports usao_tabbed_box majors_and_professionals usao_art_and_ideas usao_future_students usao_current_students usao_calendar usao_majors"
  end

  execute "update-drupal-database" do
      cwd "/var/www/drupal6/sites/d6mig.usao.dev"
      command "drush updb -y"
      action :run
  end

  execute "clear-errors-to-let-caches-clear" do
      cwd "/var/www/drupal6/sites/d6mig.usao.dev"
      command "drush updb -y"
      action :run
  end

  execute "enable-stage-file-proxy" do
      cwd "/var/www/drupal6/sites/d6mig.usao.dev"
      command "drush en -y stage_file_proxy"
      action :run
      ignore_failure true
  end

  execute "change-sites-directoy-permissions" do
      command "chmod a-w /var/www/drupal6/sites/d6mig.usao.dev"
  end

  execute "clear-errors-to-let-caches-clear" do
      cwd "/var/www/drupal6/sites/d6mig.usao.dev"
      command "drush updb -y"
      action :run
  end

  execute "disable-modules-to-allow-login" do
      cwd "/var/www/drupal6/sites/d6mig.usao.dev"
      command "drush dis -y securepages"
      action :run
      ignore_failure true
  end

  bash "set-files-directory" do
      code <<-EOH
        cd /var/www/drupal6/sites
#        drush vset --yes file_directory_path "sites/d6mig.usao.dev/files"
#        drush vset --yes file_directory_temp "sites/d6mig.usao.dev/private/temp"
        mkdir usao.edu/
        mkdir usao.edu/files
        mkdir usao.edu/private
        mkdir usao.edu/private/temp
        chgrp -R www-data usao.edu
        chmod -R g+rw usao.edu
      EOH
  end

  execute "clear-all-drupal-caches" do
      cwd "/var/www/drupal6/sites/d6mig.usao.dev"
      command "drush cc all"
      action :run
  end

  include_recipe "apache"

  web_app "usaod6" do
    server_name node[:fqdn]
    server_aliases [node[:hostname], " d6mig.usao.dev"]
    docroot "/var/www/drupal6"
  end
