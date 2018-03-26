defaults 'disable photos app from launching when device is plugged in' do
  domain 'com.apple.ImageCapture'
  option '-currentHost write'
  settings 'disableHotPlug' => true
  user node['macos']['admin_user']
end
