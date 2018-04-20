if node['platform_version'].match? Regexp.union '10.13'
  execute 'Disable Gatekeeper' do
    command ['spctl', '--master-disable']
  end

  include_recipe 'macos::xcode'

elsif node['platform_version'].match? Regexp.union '10.12'
  xcode '9.2' do
    path '/Applications/Xcode_9.2.app'
    ios_simulators %w(11 10)
  end

elsif node['platform_version'].match? Regexp.union '10.11'
  xcode '8.2.1' do
    ios_simulators %w(10 9)
  end
end
