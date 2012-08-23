#
# Cookbook Name:: usaod7
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#



  #bash "create-drupal-6-database" do
  #  code <<-EOH
  #    if [ /mnt/usao_backups/mysqldumps/current/usaoedu.sql.gz -nt /var/migration_data/usaoedu.sql ];
  #      then
  #        #zcat /mnt/usao_backups/mysqldumps/current/usaoedu.sql.gz > /var/migration_data/usaoedu.sql;
  #        zcat /mnt/usao_backups/mysqldumps/current/usaoedu.sql.gz | sed '1i \
  #        SET AUTOCOMMIT = 0; \
  #        SET FOREIGN_KEY_CHECKS=0;' | sed '$a \
  #        SET FOREIGN_KEY_CHECKS = 1; \
  #        COMMIT; \
  #        SET AUTOCOMMIT = 1;' > /var/migration_data/usaoedu.sql
  #        mysql -u root -p#{node[:mysql][:server_root_password]} usaoedu < /var/migration_data/usaoedu.sql;
  #      else
  #        echo "File 1 is older than file 2";
  #    fi;
  #EOH
  #end

  # move files from s3fs to disk
  #execute "move-d6-migration-data" do
  #  command "zcat /mnt/usao_backups/mysqldumps/current/usaoedu.sql.gz | sed '1i \
  #    SET AUTOCOMMIT = 0; \
  #    SET FOREIGN_KEY_CHECKS=0;' | sed '$a \
  #    SET FOREIGN_KEY_CHECKS = 1; \
  #    COMMIT; \
  #    SET AUTOCOMMIT = 1;' > /var/migration_data/usaoedu.sql"
  #  not_if "find /var/migration_data/usaoedu.sql -newer /mnt/usao_backups/mysqldumps/current/usaoedu.sql.gz | grep -q usaoedu.sql"
  #end

  # create a drupal db
  #execute "add-drupal-6-db" do
  #  command "/usr/bin/mysql -u root -p#{node[:mysql][:server_root_password]} -e \"" +
  #      "CREATE DATABASE usaoedu;\""
  #  action :run
  #  ignore_failure true
  #end

  # import the data into the new database
  #execute "create-d6-migration-database" do
  #  command "mysql -u root -p#{node[:mysql][:server_root_password]} usaoedu < /var/migration_data/usaoedu.sql"
  #  not_if do
  #    File.exists?("/var/lib/mysql/usaoedu/users.frm")
  #  end
  #end

  #execute "download-drupal-7" do
  #  command "drush dl --drupal-project-rename=#{ node[:d7][:directory] } --destination=/var/www"
  #end

  #bash "create-#{ node[:d7][:directory] }-directory" do
  #  code <<-EOH
  #    cd /var
  #    if [ -d "/var/www/#{ node[:d7][:directory] }" ];
  #      then
  #          echo "file made alreay";
  #      else
  #          mkdir www/#{ node[:d7][:directory] };
  #      fi;
  #  EOH
  #end

  #template "/var/www/#{ node[:d7][:directory] }/usaod7core.make" do
  #  source "usaod7core.make"
  #  mode 0440
  #end

  #execute "drush-make-drupal-7-core" do
  #    cwd "/var/www/#{ node[:d7][:directory] }"
  #    command "drush make -y usaod7core.make"
  #    not_if do
  #      File.exists?("/var/www/#{ node[:d7][:directory] }/index.php")
  #    end
  #end

  #bash "create-site-directory-and-change-permissions" do
  #  code <<-EOH
  #      if [ -d "www/#{ node[:d7][:directory] }/sites/#{ node[:d7][:site] }" ];
  #          then
  #              echo "changes made previosly";
  #          else
  #              cd /var
  #              mkdir www/#{ node[:d7][:directory] }/sites/#{ node[:d7][:site] }
  #              mkdir www/#{ node[:d7][:directory] }/sites/#{ node[:d7][:site] }/files
  #              mkdir www/#{ node[:d7][:directory] }/profiles/usaod7
  #              find #{ node[:d7][:directory] } -type d -exec chmod g+rwxs {} \;find drupal7 -type d -exec chmod g+rwxs {} \;
  #              chgrp -R www-data www/#{ node[:d7][:directory] }
  #              chmod -R g+rw www/#{ node[:d7][:directory] }
  #          fi;
  #  EOH
  #  not_if do
  #    File.exists?("/var/www/#{ node[:d7][:directory] }/sites/#{ node[:d7][:site] }/files")
  #  end
  #end

  execute "download-drupal-7" do
    command "drush dl --drupal-project-rename=#{ node[:d7][:directory] } --destination=/var/www"
  end

  template "/var/www/#{ node[:d7][:directory] }/usaod7.make" do
    source "usaod7.make"
    mode 0440
    not_if do
      File.exists?("/var/www/#{ node[:d7][:directory] }/sites/#{ node[:d7][:site] }/modules")
    end
  end

  directory "/var/www/#{ node[:d7][:directory] }/profiles/usaod7" do
    mode 0755
    action :create
  end

  template "/var/www/#{ node[:d7][:directory] }/profiles/usaod7/usaod7.install" do
    source "usaod7.install"
    mode 0440
  end

  template "/var/www/#{ node[:d7][:directory] }/profiles/usaod7/usaod7.profile" do
    source "usaod7.profile"
    mode 0440
  end

  template "/var/www/#{ node[:d7][:directory] }/profiles/usaod7/usaod7.info" do
    source "usaod7.info.erb"
    mode 0440
  end

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
  #    command "chmod a-w /var/www/#{ node[:d7][:directory] }/sites/default"
  #end

  directory "/var/www/#{ node[:d7][:directory] }/sites/#{ node[:d7][:site] }" do
    mode 0755
    action :create
  end

  template "/var/www/#{ node[:d7][:directory] }/sites/#{ node[:d7][:site] }/settings.php" do
    source "d7settings.php.erb"
    mode 0440
    notifies :restart, resources("service[varnish]"), :delayed
  end

  execute "download-drupal-7-modules" do
    cwd "/var/www/#{ node[:d7][:directory] }/sites/#{ node[:d7][:site] }"
    command "drush make -y --no-core --working-copy --contrib-destination=. /var/www/#{ node[:d7][:directory] }/usaod7.make"
    not_if do
      File.exists?("/var/www/#{ node[:d7][:directory] }/sites/#{ node[:d7][:site] }/modules")
    end
  end

  execute "install-drupal-7" do
    cwd "/var/www/#{ node[:d7][:directory] }/sites/#{ node[:d7][:site] }"
    command "drush site-install -y usaod7 --site-name='#{ node[:d7][:site_name] }' --sites-subdir='#{ node[:d7][:site] }' --account-name=#{ node[:d7][:account_name] } --account-pass=#{ node[:d7][:account_pass] } --account-mail='#{ node[:d7][:account_mail] }' --db-url=mysql://root:#{node[:mysql][:server_root_password]}@localhost/#{ node[:d7][:directory] }"
    ignore_failure true
    not_if do
      File.exists?("/var/lib/mysql/#{ node[:d7][:directory] }/users.frm")
    end
  end

  include_recipe "apache2"

  web_app "#{ node[:d7][:directory] }" do
    server_name node[:fqdn]
    server_aliases [node[:hostname], " #{ node[:d7][:site] }"]
    docroot "/var/www/#{ node[:d7][:directory] }"
  end
