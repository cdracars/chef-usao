#
# Cookbook Name:: usao
# Recipe:: default
#
# Copyright 2012, Dracars Designs
#
# All rights reserved - Do Not Redistribute
#

  execute "download-drupal-7-modules" do
    cwd "#{ node['drupal']['dir'] }/"
    command "drush make -y --no-core --working-copy --no-gitinfofile https://raw.github.com/cdracars/d7.usao.edu/master/d7_usao_edu.build"
    not_if do
      File.exists?("#{ node['drupal']['dir'] }/profiles/d7_usao_edu/modules/contrib")
    end
  end

  execute "install-drupal-7" do
    cwd "#{ node['drupal']['dir'] }/sites/default"
    command "drush site-install -y \
    d7_usao_edu \
    --site-name='#{ node['usao']['site_name'] }' \
    --site-mail='#{ node['usao']['site_mail'] }' \
    --account-name=#{ node['usao']['account_name'] } \
    --account-pass=#{ node['usao']['account_pass'] } \
    --account-mail='#{ node['usao']['account_mail'] }' \
    --db-url=mysql://#{ node['drupal']['db']['user'] }:#{ node['drupal']['db']['password'] }@localhost/#{ node['drupal']['db']['database'] }"
    not_if do
      File.exists?("/var/lib/mysql/#{ node['drupal']['db']['database'] }/ctools_css_cache.frm")
    end
  end

  execute "rebuild-permissions" do
    cwd "#{ node['drupal']['dir'] }/sites/default"
    command "drush php-eval 'node_access_rebuild();'"
    ignore_failure true
  end
