#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2015, ikuwow
#
# All rights reserved - Do Not Redistribute
#

%w{vim man tree gcc make postfix patch kernel-devel cmake mlocate expect rsync dig}.each do |pkg|
    package pkg do
        action :install
    end
end
