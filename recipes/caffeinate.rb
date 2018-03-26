launchd 'caffeinate daemon' do
  program_arguments ['/usr/bin/caffeinate', '-d', '-i']
  label 'com.microsoft.chef.caffeinate'
  run_at_load true
  session_type 'system'
  action [:create, :enable]
end
