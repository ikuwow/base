#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2015, ikuwow
#
# All rights reserved - Do Not Redistribute
#

%w{vim tree gcc make postfix patch cmake mlocate expect rsync}.each do |pkg|
    package pkg do
        action :install
    end
end

# if redhat, install below:
# man, kernel-devel
#
# decide whether to install: dig


