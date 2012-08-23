#
# Cookbook Name:: usaod7
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

  # create a drupal db
  execute "add-drupal-6-db" do
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

  execute "download-drupal-7" do
    command "drush dl --drupal-project-rename=#{ node[:clean][:directory] } --destination=/var/www"
  end

  #bash "create-#{ node[:clean][:directory] }-directory" do
  #  code <<-EOH
  #    cd /var
  #    if [ -d "/var/www/#{ node[:clean][:directory] }" ];
  #      then
  #          echo "file made alreay";
  #      else
  #          mkdir www/#{ node[:clean][:directory] };
  #      fi;
  #  EOH
  #end

  #template "/var/www/#{ node[:clean][:directory] }/usaod7core.make" do
  #  source "usaod7core.make"
  #  mode 0440
  #end

  #execute "drush-make-drupal-7-core" do
  #    cwd "/var/www/#{ node[:clean][:directory] }"
  #    command "drush make -y usaod7core.make"
  #    not_if do
  #      File.exists?("/var/www/#{ node[:clean][:directory] }/index.php")
  #    end
  #end

  #bash "create-site-directory-and-change-permissions" do
  #  code <<-EOH
  #      if [ -d "www/#{ node[:clean][:directory] }/sites/#{ node[:clean][:site] }" ];
  #          then
  #              echo "changes made previosly";
  #          else
  #              cd /var
  #              mkdir www/#{ node[:clean][:directory] }/sites/#{ node[:clean][:site] }
  #              mkdir www/#{ node[:clean][:directory] }/sites/#{ node[:clean][:site] }/files
  #              mkdir www/#{ node[:clean][:directory] }/profiles/usaod7
  #              find #{ node[:clean][:directory] } -type d -exec chmod g+rwxs {} \;find drupal7 -type d -exec chmod g+rwxs {} \;
  #              chgrp -R www-data www/#{ node[:clean][:directory] }
  #              chmod -R g+rw www/#{ node[:clean][:directory] }
  #          fi;
  #  EOH
  #  not_if do
  #    File.exists?("/var/www/#{ node[:clean][:directory] }/sites/#{ node[:clean][:site] }/files")
  #  end
  #end

  template "/var/www/#{ node[:clean][:directory] }/usaod7.make" do
    source "usaod7.make"
    mode 0440
    not_if do
      File.exists?("/var/www/#{ node[:clean][:directory] }/sites/#{ node[:clean][:site] }/modules")
    end
  end

  #directory "/var/www/#{ node[:clean][:directory] }/profiles/usaod7" do
  #  mode 0755
  #  action :create
  #end

  #template "/var/www/#{ node[:clean][:directory] }/profiles/usaod7/usaod7.install" do
  #  source "usaod7.install"
  #  mode 0440
  #end

  #template "/var/www/#{ node[:clean][:directory] }/profiles/usaod7/usaod7.profile" do
  #  source "usaod7.profile"
  #  mode 0440
  #end

  #template "/var/www/#{ node[:clean][:directory] }/profiles/usaod7/usaod7.info" do
  #  source "usaod7.info.erb"
  #  mode 0440
  #end

  # Add an admin user to mysql
  #execute "add-mysql-admin-user" do
  #  command "/usr/bin/mysql -u root -p#{node[:mysql][:server_root_password]} -e \"" +
  #      "GRANT ALL PRIVILEGES ON *.* TO 'usao'@'localhost' IDENTIFIED BY '#{node[:mysql][:server_root_password]}' WITH GRANT OPTION;" +
  #      "GRANT ALL PRIVILEGES ON *.* TO 'usao'@'%' IDENTIFIED BY '#{node[:mysql][:server_root_password]}' WITH GRANT OPTION;\" " +
  #      "mysql"
  #  action :run
  #end

  # Create a drupal db
  #execute "add-drupal-db" do
  #  command "/usr/bin/mysql -u root -p#{node[:mysql][:server_root_password]} -e \"" +
  #      "CREATE DATABASE usaod7;\""
  #  action :run
  #  ignore_failure true
  #end

  #execute "change-sites-directoy-permissions" do
  #    command "chmod a-w /var/www/#{ node[:clean][:directory] }/sites/default"
  #end

  directory "/var/www/#{ node[:clean][:directory] }/sites/#{ node[:clean][:site] }" do
    mode 0755
    action :create
  end

  template "/var/www/#{ node[:clean][:directory] }/sites/#{ node[:clean][:site] }/settings.php" do
    source "d7settings.php.erb"
    mode 0440
    notifies :restart, resources("service[varnish]"), :delayed
  end

  execute "download-drupal-7-modules" do
    cwd "/var/www/#{ node[:clean][:directory] }/sites/#{ node[:clean][:site] }"
    command "drush make -y --no-core --contrib-destination=. /var/www/#{ node[:clean][:directory] }/usaod7.make"
    not_if do
      File.exists?("/var/www/#{ node[:clean][:directory] }/sites/#{ node[:clean][:site] }/modules")
    end
  end

  execute "install-drupal-7" do
    cwd "/var/www/#{ node[:clean][:directory] }/sites/#{ node[:clean][:site] }"
    command "drush site-install -y minimal --site-name='#{ node[:clean][:site_name] }' --sites-subdir='#{ node[:clean][:site] }' --account-name=#{ node[:clean][:account_name] } --account-pass=#{ node[:clean][:account_pass] } --account-mail='#{ node[:clean][:account_mail] }' --db-url=mysql://root:#{node[:mysql][:server_root_password]}@localhost/#{ node[:clean][:directory] }"
    ignore_failure true
    not_if do
      File.exists?("/var/lib/mysql/#{ node[:clean][:directory] }/users.frm")
    end
  end

  execute "enable-modules" do
    cwd "/var/www/#{ node[:clean][:directory] }/sites/#{ node[:clean][:site] }"
    command "drush en -y usao_courses admin_tools"
  end

  execute "enable-&-set-default-theme" do
    cwd "/var/www/#{ node[:clean][:directory] }/sites/#{ node[:clean][:site] }"
    command "drush vset default_theme gray_n_green"
  end

  execute "set-admin-theme" do
    cwd "/var/www/#{ node[:clean][:directory] }/sites/#{ node[:clean][:site] }"
    command "drush vset admin_theme rubik"
  end

  include_recipe "apache2"

  web_app "#{ node[:clean][:directory] }" do
    server_name node[:fqdn]
    server_aliases [node[:hostname], " #{ node[:clean][:site] }"]
    docroot "/var/www/#{ node[:clean][:directory] }"
  end
