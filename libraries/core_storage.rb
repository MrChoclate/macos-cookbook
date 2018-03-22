require 'yaml'

class CoreStorage
  def initialize(group_identifier)
    @group_info = YAML.load(`diskutil cs info #{group_identifier}`)
  end

  def self.all
    `diskutil cs list`.scan(/Logical Volume Group ([A-Z0-9-]+)$/).map do |group|
      new group
    end
  end
end
