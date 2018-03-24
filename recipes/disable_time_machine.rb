plist 'disable time machine prompts for backup' do
  path '/Library/Preferences/com.apple.TimeMachine.plist'
  entry 'DoNotOfferNewDisksForBackup'
  value true
  encoding 'binary'
end
