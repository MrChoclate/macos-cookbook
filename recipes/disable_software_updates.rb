execute 'disable automatic background check via command' do
  command [softwareupdate_command, '--schedule', 'off']
  not_if { automatic_checked_disabled? }
end

plist 'disable automatic software update check' do
  path '/Library/Preferences/com.apple.SoftwareUpdate.plist'
  entry 'AutomaticCheckEnabled'
  value false
end

plist 'disable automatic software update downloads' do
  path '/Library/Preferences/com.apple.SoftwareUpdate.plist'
  entry 'AutomaticDownload'
  value false
end
