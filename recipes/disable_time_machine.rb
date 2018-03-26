execute 'disable time machine' do
  command ['/usr/bin/tmutil', 'disable']
  settings = setting_from_plist 'AutoBackup', '/Library/Preferences/com.apple.TimeMachine.plist'
  not_if { settings[:key] == 'false' && settings[:key_type] == 'boolean' }
end

plist 'disable time machine prompts for backup' do
  path '/Library/Preferences/com.apple.TimeMachine.plist'
  entry 'DoNotOfferNewDisksForBackup'
  value true
  encoding 'binary'
end

plist 'disable time machine backup' do
  path '/Library/Preferences/com.apple.TimeMachine.plist'
  entry 'AutoBackup'
  value false
  encoding 'binary'
end
