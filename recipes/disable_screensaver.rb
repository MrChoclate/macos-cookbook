defaults 'com.apple.screensaver' do
  option '-currentHost write'
  settings 'idleTime' => 0
  not_if { screensaver_disabled? }
  user node['macos']['admin_user']
end
