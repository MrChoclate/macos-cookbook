require 'yaml'

#
# Chef Documentation
# https://docs.chef.io/libraries.html
#

#
# This module name was auto-generated from the cookbook name. This name is a
# single word that starts with a capital letter and then continues to use
# camel-casing throughout the remainder of the name.
#
module ChangeosSetupCookbook
  module ChangeosSetupHelpers
    def get_volume_to_name
      data = YAML.load(`/usr/sbin/system_profiler SPStorageDataType`)
      data['Storage'].keys
    end

    def rename_volume
      nil
    end
  end
end

# volume_name=$(diskutil info / | grep "Volume Name" | cut -c 30-)
#
# if [ "$volume_name" != "ChangeOS" ]; then
#   diskutil renameVolume "$volume_name" "ChangeOS"
#   fi

#
# The module you have defined may be extended within the recipe to grant the
# recipe the helper methods you define.
#
# Within your recipe you would write:
#
#     extend ChangeosSetupCookbook::DefaultHelpers
#
#     my_helper_method
#
# You may also add this to a single resource within a recipe:
#
#     template '/etc/app.conf' do
#       extend ChangeosSetupCookbook::DefaultHelpers
#       variables specific_key: my_helper_method
#     end
