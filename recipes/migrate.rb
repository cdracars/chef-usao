  # move files from s3fs to disk
  execute "move-d6-migration-data" do
    command "zcat /mnt/usao_backups/mysqldumps/current/usaoedu.sql.gz | sed '1i \
      SET AUTOCOMMIT = 0; \
      SET FOREIGN_KEY_CHECKS=0;' | sed '$a \
      SET FOREIGN_KEY_CHECKS = 1; \
      COMMIT; \
      SET AUTOCOMMIT = 1;' > /var/migration_data/usaoedu.sql"
    not_if "find /var/migration_data/usaoedu.sql -newer /mnt/usao_backups/mysqldumps/current/usaoedu.sql.gz | grep -q usaoedu.sql"
  end

  # create a drupal db
  execute "add-drupal-6-db" do
    command "/usr/bin/mysql -u root -p#{node['mysql']['server_root_password']} -e \"" +
        "CREATE DATABASE usaoedu;\""
    action :run
    ignore_failure true
  end

  # import the data into the new database
  execute "create-d6-migration-database" do
    command "mysql -u root -p#{node['mysql']['server_root_password']} usaoedu < /var/migration_data/usaoedu.sql"
    not_if do
      File.exists?("/var/lib/mysql/usaoedu/users.frm")
    end
  end

  execute "cleanup-drupal-6-users-data" do
    command "mysql -uroot -p#{node['mysql']['server_root_password']} -e 'DELETE FROM usaoedu.role WHERE rid = 3'"
  end

  execute "migrate-drupal-6-users" do
    cwd "/var/www/drupal7/sites/d7mig.usao.dev"
    command "drush migrate-import 'D6User'"
    ignore_failure true
  end

  execute "migrate-drupal-6-courses" do
    cwd "/var/www/drupal7/sites/d7mig.usao.dev"
    command "drush migrate-import 'D6Course'"
    ignore_failure true
  end
