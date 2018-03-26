module MacOS
  module SoftwareUpdates
    def updates_available?
      no_new_software_pattern = Regexp.union 'No new software available.'
      command = shell_out softwareupdate_command, '--list', '--all'
      command.stderr.chomp.match? no_new_software_pattern
    end

    def automatic_checked_disabled?
      automatic_check_is_off_pattern = Regexp.union 'Automatic check is off'
      command = shell_out softwareupdate_command, '--schedule'
      command.stdout.chomp.match? automatic_check_is_off_pattern
    end

    def softwareupdate_command
      '/usr/sbin/softwareupdate'
    end
  end
end

Chef::Recipe.include(MacOS::SoftwareUpdates)
Chef::Resource.include(MacOS::SoftwareUpdates)
