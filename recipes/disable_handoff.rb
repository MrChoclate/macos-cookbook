plist 'disable handoff receiving' do
  path "/Users/#{node['macos']['admin_user']}/Library/Preferences/com.apple.coreservices.useractivityd.#{hardware_uuid}.plist"
  entry 'ActivityReceivingAllowed'
  value false
  notifies :run, 'defaults[disable handoff receiving]'
end

defaults 'disable handoff receiving' do
  domain 'com.apple.coreservices.useractivityd'
  option '-currentHost write'
  settings 'ActivityReceivingAllowed' => false
  user node['macos']['admin_user']
  action :nothing
end

plist 'disable handoff advertising' do
  path "/Users/#{node['macos']['admin_user']}/Library/Preferences/com.apple.coreservices.useractivityd.#{hardware_uuid}.plist"
  entry 'ActivityAdvertisingAllowed'
  value false
  notifies :run, 'defaults[disable handoff advertising]'
end

defaults 'disable handoff advertising' do
  domain 'com.apple.coreservices.useractivityd'
  option '-currentHost write'
  settings 'ActivityAdvertisingAllowed' => false
  user node['macos']['admin_user']
  action :nothing
end
