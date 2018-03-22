#!/usr/bin/ruby

require 'logger'
require 'yaml'

LOGGER = Logger.new('/var/log/smartpart.log')
LOGGER.level = Logger::DEBUG

class SmartPart
  def initialize
    @computer = Computer.new
  end

  def dual_disk?
    internal_disks.count == 2
  end

  def single_disk?
    internal_disks.count == 1
  end

  def internal_disks
    Disk.all.select(&:internal?)
  end

  def external_disks
    Disk.all.select do |disk|
      disk.external? && !disk.netboot_disk? && !disk.contains_boot_volume?
    end
  end

  def fusion_drive_installed?
    Disk.any?(&:fusion_drive?)
  end

  def core_storage_setup?
    Disk.any?(&:core_storage_member?)
  end

  def remove_core_storage!
    cs_lvg_id = `diskutil cs list | grep 'Logical Volume Group' | awk '{print $5}'`
    LOGGER.info 'Removing Core Storage LVG'
    system("diskutil cs delete #{cs_lvg_id}")
  end

  def core_storage_volumes
    Disk.all.select(&:core_storage_volume?)
  end

  def partition_automation!
    deal_with_core_storage
    if dual_disk?
      LOGGER.info '2 Internal Disks Detected'
      internal_disks.each_with_index do |disk, index|
        disk.erase!(name: ['ChangeOS', 'Mac OS X'][index])
      end

    elsif single_disk?
      LOGGER.info 'Single Internal Disk Detected'
      internal_disks[0].partition! scheme: 'GPT',
                                   partitions: [
                                     { name: 'ChangeOS' },
                                     { name: 'Mac OS X' },
                                   ]

    else
      LOGGER.info 'Unknown Disk Configuration for Automation. Please use Disk Utility'
    end
  end

  def partition_build!
    deal_with_core_storage
    if single_disk? && external_disks.count == 0
      LOGGER.info 'Single Internal Disk Detected'
      internal_disks[0].partition! scheme: 'GPT',
                                   partitions: [
                                     { name: 'Reimage', size: '20G' },
                                     { name: 'Server',  size: '90G' },
                                     { name: 'Data',    size: 'R' },
                                   ]

    elsif single_disk? && external_disks.count > 0
      internal_disks[0].partition! scheme: 'GPT',
                                   partitions: [
                                     { name: 'Reimage', size: '20G' },
                                     { name: 'Server',  size: '90G' },
                                     { name: 'Data',    size: 'R' },
                                   ]

    else
      LOGGER.info 'Unknown Disk Configuration for Build. Launching Disk Utility'
    end
  end

  def deal_with_core_storage
    if fusion_drive_installed?
      LOGGER.info 'Fusion Drives Not Yet Supported. Launching Disk Utility'
    end
    remove_core_storage! if core_storage_setup?
  end

  def auto_setup
    if @computer.automation_machine?
      LOGGER.info 'Automation Machine Detected'
      partition_automation!
      # Sleeping to allow Imagr to refresh mounts
      sleep 20
    elsif @computer.build_machine?
      LOGGER.info 'Build Machine Detected'
      partition_build!
      # Sleeping to allow Imagr to refresh mounts
      sleep 20
    else
      LOGGER.fatal('Unknown machine configuration detected.')
      exit 1
    end
  end
end
