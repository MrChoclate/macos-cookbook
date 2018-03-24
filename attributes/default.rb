default['macos']['admin_user'] = 'vagrant'
default['macos']['admin_password'] = 'vagrant'

default['macos']['mono']['package'] = 'MonoFramework-MDK-4.4.2.11.macos10.xamarin.universal.pkg'
default['macos']['mono']['version'] = '4.4.2'
default['macos']['mono']['checksum'] = 'd8bfbee7ae4d0d1facaf0ddfb70c0de4b1a3d94bb1b4c38e8fa4884539f54e23'

default['macos']['xcode']['version'] = '9.2'
default['macos']['xcode']['simulator']['major_version'] = %w(11 10)

default['macos']['remote_login_enabled'] = true
default['macos']['disk_sleep_disabled'] = false

default['macos']['network_time_server'] = 'time.windows.com'
default['macos']['time_zone'] = 'America/Los_Angeles'

default['macos']['image_capture']['hot_plug'] = true
default['macos']['software_updates']['download'] = false
default['macos']['software_updates']['check_for_updates'] = false

default['macos']['bluetooth']['keyboard_missing'] = false
default['macos']['bluetooth']['mouse_missing'] = false

default['macos']['new_to_mac'] = false
default['macos']['remote_management'] = true
default['macos']['time_machine']['offer_new_disks'] = false
default['macos']['screensaver']['idle_time'] = false
