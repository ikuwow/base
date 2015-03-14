#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2015, ikuwow
#
# All rights reserved - Do Not Redistribute
#

%w{vim tree gcc make patch cmake mlocate expect rsync}.each do |pkg|
    package pkg do
        action :install
    end
end

# if redhat, install below:
# kernel-devel
#
# decide whether to install: dig

case node['platform']
when 'centos', 'redhat'
    package "man" do
        action :install
    end
end

include_recipe "selinux::disabled"
