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

# SELinux disabled
include_recipe "selinux::disabled"

# degawaユーザーの作成
user_data = data_bag_item('users','degawa')

# ikuwow group (allowed to sudo with password)
# TODO: allow ikuwow group to sudo with password

human_group = "ikuwow"
group human_group do
    action :create
end

# Sudoers

node.default['authorization']['sudo']['groups'] = ["ikuwow","root"]
node.default['authorization']['sudo']['include_sudoers_d'] = true

include_recipe "sudo::default"

sudo 'vagrant' do
    user 'vagrant'
    runas 'ALL'
    nopasswd true
    commands ['ALL']
end

user user_data["id"] do
    supports :manage_home => true
    home "/home/#{user_data["id"]}"
    shell "/bin/bash"
    gid human_group
    action :create
end

# passwordは手動で設定すること

# ssh鍵設置
directory "/home/#{user_data["id"]}/.ssh/" do
    user user_data["id"]
    group human_group
    mode 0700
    action :create
end

file "/home/#{user_data["id"]}/.ssh/authorized_keys" do
    content user_data["public_keys"]
    user user_data["id"]
    group human_group
    mode 0600
    action :create
end
