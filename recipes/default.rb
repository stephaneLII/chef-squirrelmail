#
# Cookbook Name:: chef-squirrelmail
# Recipe:: default
#
# Copyright (c) 2014 The Authors, All Rights Reserved.
include_recipe "apt::default"

package "squirrelmail"
package "squirrelmail-locales"
package "php5-ldap"

squirrel_home = node['chef-squirrelmail']['squirrel_home']
apache_home = node['chef-squirrelmail']['apache2_home']
site_name = node['chef-squirrelmail']['site_name']
site_name_ssl = node['chef-squirrelmail']['site_name'] + "-ssl"
site_home = node['chef-squirrelmail']['site_home']

if node['chef-squirrelmail']['databag']['encrypted'] == true
  secret = Chef::EncryptedDataBagItem.load_secret(node['chef-squirrelmail']['databag']['secret_path'])
  item =  Chef::EncryptedDataBagItem.load(node['chef-squirrelmail']['databag']['name'], node['chef-squirrelmail']['databag']['item'], secret)
else
  item = data_bag_item(node['chef-squirrelmail']['databag']['name'], node['chef-squirrelmail']['databag']['item'])
end

item['apps'].each do |apps|
   cakey=apps['cakey']
   cakeyname=apps['cakeyname']
   pemkey=apps['key']
   crtkey=apps['cert']

   template '/etc/ssl/certs/' + cakeyname + '.crt' do
    source 'certificate.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      certificate: cakey
    )
  end


  template '/etc/ssl/certs/' + node['chef-squirrelmail']['virtualhost_name'] + '.crt' do
    source 'certificate.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      certificate: crtkey
    )
  end

  template '/etc/ssl/private/' + node['chef-squirrelmail']['virtualhost_name'] + '.key' do
    source 'certificate.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      certificate: pemkey
    )
  end

   template "#{apache_home}/sites-available/#{site_name}" do
     source 'config-virtualhost.erb'
     owner 'root'
     group 'root'
     mode '0644'
   end

   template "#{apache_home}/sites-available/#{site_name}-ssl" do
     source 'config-virtualhost-ssl.erb'
     owner 'root'
     group 'root'
     mode '0644'
     variables(
      cakeyname: cakeyname + '.crt'
     )
   end

   bash 'site-enable' do
     user 'root'
     code <<-EOH
        a2ensite #{site_name}
        a2ensite #{site_name_ssl}
     EOH
end

end
case node['platform']
  when 'ubuntu'
    restart_command = '/usr/sbin/a2enmod ssl ; /etc/init.d/apache2 restart'
  when 'debian'
    restart_command = '/usr/sbin/a2enmod ssl ; /etc/init.d/apache2 restart'
end

bash 'squirrelmail-restart' do
  user 'root'
  code <<-EOH
    #{restart_command}
  EOH
end

directory node['chef-squirrelmail']['data_home'] do
  owner "#{node['chef-squirrelmail']['apache_owner']}"
  group "#{node['chef-squirrelmail']['apache_group']}"
  mode '0755'
  action :create
end

cookbook_file 'logo-SI.gif' do
  path "#{site_home}/#{node['chef-squirrelmail']['org_logo']}"
  action :create
  mode '0644'
  owner "#{node['chef-squirrelmail']['apache_owner']}"
  group "#{node['chef-squirrelmail']['apache_group']}"
end

cookbook_file 'adressebook' do
  path "#{site_home}/#{node['chef-squirrelmail']['data_dir']}#{node['chef-squirrelmail']['abook_global_file']}"
  action :create
  mode '0770'
  owner "#{node['chef-squirrelmail']['apache_owner']}"
  group "#{node['chef-squirrelmail']['apache_group']}"
end

###############################################
# config de webmail via config.erb
###############################################

template "#{site_home}/config/config.php" do
  source 'config.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template "#{site_home}/functions/i18n.php" do
  source 'i18n.erb'
  owner "#{node['chef-squirrelmail']['apache_owner']}"
  group "#{node['chef-squirrelmail']['apache_group']}"
  mode '0644'
end
template "#{site_home}/functions/strings.php" do
  source 'strings.erb'
  owner "#{node['chef-squirrelmail']['apache_owner']}"
  group "#{node['chef-squirrelmail']['apache_group']}"
  mode '0644'
end
