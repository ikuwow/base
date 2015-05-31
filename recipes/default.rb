#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2015, ikuwow
#
# All rights reserved - Do Not Redistribute
#

# Kernel Parameters
swappiness_value = 10
bash "Set swappiness" do
    code <<-EOC
        echo #{swappiness_value} > /proc/sys/vm/swappiness
        sysctl -w vm.swappiness=#{swappiness_value}
    EOC
    action :run
    not_if "test `sysctl -n vm.swappiness` = #{swappiness_value}"
end

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

timezone 'Asia/Tokyo'
node.default['ntp']['servers'] = ['ntp.nict.jp','ntp.jst.mfeed.ad.jp','s2csntp.miz.nao.ac.jp']
include_recipe 'ntp::default'

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
node.default['authorization']['sudo']['sudoers_defaults'] = [
    '!visiblepw',
    'env_reset',
    'secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"'
    # does not include requiretty
]

if node["platform"] == "centos"
    node.default['authorization']['sudo']['sudoers_defaults'].concat([
        'env_keep =  "COLORS DISPLAY HOSTNAME HISTSIZE INPUTRC KDEDIR LS_COLORS"',
        'env_keep += "MAIL PS1 PS2 QTDIR USERNAME LANG LC_ADDRESS LC_CTYPE"',
        'env_keep += "LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES"',
        'env_keep += "LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE"',
        'env_keep += "LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY"'
    ])
end

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

# 各ユーザーのpasswordは手動で設定すること

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
