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

# degawaユーザーの作成
user_data = data_bag_item('users','degawa')

user user_data["id"] do
    supports :manage_home => true
    home "/home/#{user_data["id"]}"
    shell "/bin/bash"
    gid "sudo"
    action :create
end

# passwordは手動で設定すること

# ssh鍵設置
directory "/home/#{user_data["id"]}/.ssh/" do
    user user_data["id"]
    group user_data["id"]
    mode 0700
    action :create
end

file "/home/#{user_data["id"]}/.ssh/authorized_keys" do
    content user_data["public_keys"]
    user user_data["id"]
    group user_data["id"]
    mode 0600
    action :create
end
