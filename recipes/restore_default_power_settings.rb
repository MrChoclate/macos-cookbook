power_sentinel = ::File.join Chef::Config[:file_cache_path], '.pmset.restoredefaults'

execute 'restore default power settings' do
  command ['/usr/bin/pmset', 'restoredefaults']
  notifies :create, 'file[power sentinel file]'
  not_if { ::File.exist? power_sentinel }
end

ruby_block 'sleep after restore' do
  block { sleep 1 }
  action :nothing
end

file 'power sentinel file' do
  path power_sentinel
  notifies :run, 'ruby_block[sleep after restore]', :immediately
end
