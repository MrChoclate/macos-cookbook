$LOAD_PATH.unshift(*Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)])
require 'xcode/install'
include Chef::Mixin::ShellOut

module MacOS
  class Xcode
    attr_reader :version

    def initialize(semantic_version)
      @semantic_version = semantic_version
      apple_version = Xcode::Version.new(@semantic_version).apple_version
      @version = available_versions_list[xcode_index(apple_version)].strip
    end

    def xcode_index(xcode_version)
      available_xcodes.index { |xcode| xcode.apple_version == xcode_version }
    end

    def available_versions_list
      shell_out!(XCVersion.list_xcodes).stdout.lines
    end

    def available_xcodes
      available_versions_list.map { |v| Xcode::Version.new v.split.first }
    end

    class Simulator
      attr_reader :version

      def initialize(major_version)
        while available_list.empty?
          Chef::Log.warn('iOS Simulator list not populated yet')
          sleep 10
        end
        if latest_semantic_version(major_version).nil?
          Chef::Application.fatal!("iOS #{major_version} Simulator no longer available from Apple!")
        else
          @version = latest_semantic_version(major_version).join(' ')
        end
      end

      def latest_semantic_version(major_version)
        requirement = Gem::Dependency.new('iOS', "~> #{major_version}")
        available_list.select { |platform, version| requirement.match?(platform, version) }.max
      end

      def available_list
        available_versions.split(/\n/).map { |version| version.split[0..1] }
      end

      def installed?
        available_versions.include?("#{@version} Simulator (installed)")
      end

      def available_versions
        shell_out!(XCVersion.list_simulators).stdout
      end

      def show_sdks
        shell_out!('/usr/bin/xcodebuild -showsdks').stdout
      end

      def included_with_xcode?
        version_matcher    = /\d{1,2}\.\d{0,2}\.?\d{0,3}/
        included_simulator = show_sdks.match(/Simulator - iOS (?<version>#{version_matcher})/)
        @version.split.last.to_i == included_simulator[:version].to_i
      end
    end

    class Version < Gem::Version
      def major
        _segments.first
      end

      def minor
        _segments[1] || 0
      end

      def patch
        _segments[2] || 0
      end

      def major_release?
        minor == 0 && patch == 0
      end

      def minor_release?
        minor != 0 && patch == 0
      end

      def patch_release?
        patch != 0
      end

      def apple_version
        if major_release?
          major
        else
          version
        end
      end
    end
  end
end

Chef::Recipe.include(MacOS)
Chef::Resource.include(MacOS)
