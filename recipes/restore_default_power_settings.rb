execute 'restore default power settings' do
  command ['/usr/bin/pmset', 'restoredefaults']
  live_stream true
  notifies :run, 'ruby_block[sleep two]', :immediately
end

execute 'restore default power settings' do
  command ['/usr/bin/pmset', 'touch']
  live_stream true
  notifies :run, 'ruby_block[sleep two]', :immediately
end

ruby_block 'sleep two' do
  block { sleep 2 }
  action :nothing
end
