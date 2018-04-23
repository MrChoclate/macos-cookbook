resource_name :xcode
default_action %i(install_xcode set_path install_simulators)

property :version, String, name_property: true
property :path, String, default: '/Applications/Xcode.app'
property :ios_simulators, Array

action :install_xcode do
  xcode = XcodeInstall::Installer.new

  ruby_block "download and install Xcode #{new_resource.version}" do
    block do
      ENV['XCODE_INSTALL_USER'] = node['macos']['apple_id']['user']
      ENV['XCODE_INSTALL_PASSWORD'] = node['macos']['apple_id']['password']
      xcode.install_version(new_resource.version, false)
    end
    not_if { xcode.installed?(new_resource.version) }
  end
end

action :set_path do
  execute "move Xcode to #{new_resource.path}" do
    command ['mv', "/Applications/Xcode-#{new_resource.version}.app", new_resource.path]
    only_if { ::File.exist?("/Applications/Xcode-#{new_resource.version}.app") }
    notifies :run, "execute[switch active Xcode to #{new_resource.path}]", :immediately
  end

  execute "switch active Xcode to #{new_resource.path}" do
    command ['xcode-select', '--switch', new_resource.path]
    action :nothing
  end
end

action :install_simulators do
  if new_resource.ios_simulators
    new_resource.ios_simulators.each do |major_version|
      simulator = Xcode::Simulator.new(major_version)
      next if simulator.included_with_xcode?

      execute "install #{simulator.version} Simulator" do
        command XCVersion.install_simulator(simulator)
        not_if { simulator.installed? }
      end
    end
  end
end
