#
# Cookbook Name:: usao
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

  bash "Clone the usao-main repo" do
    code <<-EOH
        cd /home/vagrant/
        git clone git@bitbucket.org:cdracars/usao-main.git
    EOH
  end
