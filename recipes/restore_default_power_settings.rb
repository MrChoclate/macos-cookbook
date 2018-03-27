power_sentinel = ::File.join Chef::Config[:file_cache_path], '.pmset.restoredefaults'

execute 'restore default power settings' do
  command ['/usr/bin/pmset', 'restoredefaults']
  notifies :create, 'file[restoredefaults sentinel file]'
  not_if { ::File.exist? power_sentinel }
end

file 'restoredefaults sentinel file' do
  path lazy { power_sentinel }
  notifies :run, 'ruby_block[sleep after restore]', :immediately
  action :nothing
end

ruby_block 'sleep after restore' do
  block { sleep 2 }
  action :nothing
end
