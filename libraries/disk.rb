include Chef::Mixin::ShellOut

module ChangeOS
  class Disk
    def initialize(disk_identifier, args = {})
      disk_info_cmd = shell_out diskutil_command, 'info', disk_identifier
      boot_volume_cmd = shell_out diskutil_command, 'info', '/'
      @disk_info = Psych.load disk_info_cmd.stdout
      @boot_volume = Psych.load boot_volume_cmd.stdout
      @disk_type = args[:disk_type]
    end

    def internal?
      @disk_type == 'internal, physical' || @disk_info['Internal']
    end

    def external?
      @disk_type == 'external, physical' ||
        !internal? && !read_only? && @disk_info['Ejectable']
    end

    def read_only?
      @disk_info['Read Only Media']
    end

    def contains_boot_volume?
      identifier == @boot_volume['Part of Whole']
    end

    def netboot_disk?
      @disk_info['Mount Point'].to_s == '/private/var/netboot'
    end

    def core_storage_member?
      core_storage_list_cmd = shell_out diskutil_command, 'cs', 'list'
      core_storage_list_cmd.stdout.match? identifier
    end

    def core_storage_volume?
      @disk_info.key? 'LV UUID'
    end

    def fusion_drive?
      @disk_info['Fusion Drive']
    end

    def lv_id
      @disk_info['LV UUID']
    end

    def lvg_id
      @disk_info['LVG UUID']
    end

    def name
      @disk_info['Device / Media Name']
    end

    def identifier
      @disk_info['Device Identifier']
    end

    def size
      @disk_info['Total Size'].to_i
    end

    # Completely erase an existing whole disk.  All volumes on this disk will be
    # destroyed.  Ownership of the affected disk is required.
    #
    # Usage:  my_disk.erase! format: 'JHFS+', name: 'Macintosh HD'
    #
    # :format is the specific file system abbreviation you want to format the disk
    # with (HFS+, etc.).
    #
    # :name is the (new) volume name (subject to file system naming restrictions).
    #
    # You cannot erase the boot disk.
    def erase!(args = {})
      raise 'Cannot Erase Core Storage Member' if core_storage_member?
      LOGGER.info `#{diskutil_command} eraseDisk #{args[:format] || 'JHFS+'} \"#{args[:name]}\"\\
        #{identifier}`
    end

    # (Re)Partition an existing disk. All volumes on this disk will be destroyed.
    # Ownership of the affected disk is required.
    #
    # Usage: my_disk.partition! scheme: 'GPT',
    #          partitions: [
    #            {format: 'JHFS+', name: 'Reimage', size: '40G'},
    #            {format: 'JHFS+', name: 'Server', size: 'R'}
    #          ]
    #
    # :scheme specifies a partition scheme to be used
    #    APM specifies that an Apple Partition Map scheme be created.
    #    MBR specifies that a DOS-compatible format scheme be created.
    #    GPT specifies that a GUID Partitioning scheme be created.
    # APMFormat and APMScheme are synonyms for APM; the same applies to the others
    #
    # :partitions is an array of hashes representing each partition's :name,
    #   optional :format, and optional :size.
    #
    #   :format is the specific file system name you want to erase it as (HFS+,
    #   etc.). JHFS+ is used if no :format is specified.
    #
    #   :name is the volume name (subject to file system naming restrictions).
    #
    #   :size is the length of the partition (slice); the exact resulting size may
    #     be somewhat larger or smaller as necessary in certain cases.
    #
    #   Valid sizes are floating-point numbers with a suffix of B(ytes), S(512-
    #   byte-blocks), K(ilobytes), M(egabytes), G(igabytes), T(erabytes),
    #   P(etabytes), or (%)percentage of the total size of the whole disk; also,
    #   at most 1 partition can specify a size of "R" (without a preceding number)
    #   to specify the remainder left on the whole disk after considering the
    #   other sizes.
    def partition!(args = {})
      raise 'Cannot Partition Core Storage Member' if core_storage_member?

      LOGGER.info `#{diskutil_command} partitionDisk #{identifier} #{args[:partitions].size}\\
        #{args[:scheme] || 'GPT'} #{diskutil_partition_string(args[:partitions])}`
    end

    # In 10.10 the output of diskutil list looks like this:
    #
    # /dev/disk0
    #  #:                       TYPE NAME                    SIZE       IDENTIFIER
    #  0:      GUID_partition_scheme                        *251.0 GB   disk0
    #  1:                        EFI EFI                     209.7 MB   disk0s1
    #  2:                  Apple_HFS ChangeOS                99.0 GB    disk0s2
    #  3:                  Apple_HFS                         151.5 GB   disk0s3
    #
    # In 10.11 it looks like this:
    #
    # /dev/disk0 (internal, physical):
    #  #:                       TYPE NAME                    SIZE       IDENTIFIER
    #  0:      GUID_partition_scheme                        *751.3 GB   disk0
    #  1:                        EFI EFI                     209.7 MB   disk0s1
    #  2:          Apple_CoreStorage Macintosh HD            499.4 GB   disk0s2
    #  3:                 Apple_Boot Recovery HD             650.1 MB   disk0s3
    #  4:       Microsoft Basic Data BOOTCAMP                251.0 GB   disk0s4
    # /dev/disk1 (internal, virtual):
    #  #:                       TYPE NAME                    SIZE       IDENTIFIER
    #  0:                  Apple_HFS Macintosh HD           +499.1 GB   disk1
    #                                Logical Volume on disk0s2
    #                                2F555A8B-D884-485F-985A-3B7ADF7BFCB5
    #                                Unlocked Encrypted
    #
    # The regular expression in this method matches for both scenarios. In the
    # case of 10.11 it captures the disk identifier and the disk type in
    # parenthases to the right of it. This iformation needs to be captured because
    # in 10.11 `diskutil info /dev/diskid` no longer lists the 'Internal' value
    # for the disk. In the case of 10.10, it simply captures an empty string for
    # the disk type value.
    def self.all
      `#{diskutil_command} list`.scan(%r{(\/dev\/disk\d+)(.*|)}).map do |disk|
        new disk[0], disk_type: disk[1].strip.delete('():')
      end
    end

    def self.any?(&block)
      Disk.all.any?(&block)
    end

    private

    def diskutil_command
      '/usr/sbin/diskutil'
    end

    def diskutil_partition_string(partitions)
      partitions.map do |partition|
        "#{partition[:format] || 'JHFS+'} \"#{partition[:name]}\"\\
          #{partition[:size] || (100 / partitions.size).to_s + '%'}"
      end.join(' ')
    end
  end
end
