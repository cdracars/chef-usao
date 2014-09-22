#
# Cookbook Name:: usao
# Recipe:: default
#
# Copyright 2012, Dracars Designs
#
# All rights reserved - Do Not Redistribute
#

  bash "usao-site-drush-make-download-modules" do
    cwd "#{ node['drupal']['dir'] }/"
    command "drush make -y --no-core --working-copy --no-gitinfofile https://raw.github.com/cdracars/d7.usao.edu_build/master/d7_usao_edu.build; touch #{ node['drupal']['dir'] }/profiles/d7_usao_edu/modules/delete_to_update.txt"
    not_if do
      File.exists?("#{ node['drupal']['dir'] }/profiles/d7_usao_edu/modules/delete_to_update.txt")
    end
  end

  bash "usao-site-install-drupal-7" do
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

  execute "usao-site-rebuild-permissions" do
    cwd "#{ node['drupal']['dir'] }/sites/default"
    command "drush php-eval 'node_access_rebuild();'"
    ignore_failure true
    not_if { node.attribute?("usao-site-permission-rebuilt") }
  end

  ruby_block "usao-site-permissions-rebuilt" do
    block do
      node.set['usao-site-permission-rebuilt'] = true
      node.save
    end
    action :nothing
  end
