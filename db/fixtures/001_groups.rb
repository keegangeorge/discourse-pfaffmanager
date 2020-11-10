# TODO: figure out why this is trying to re-create existing groups.
# Group.find_by_name(SiteSetting.pfaffmanager_create_server_group).destroy
# Group.find_by_name(SiteSetting.pfaffmanager_unlimited_server_group).destroy
# Group.find_by_name(SiteSetting.pfaffmanager_server_manager_group).destroy
# Group.seed do |g|
#   g.name = SiteSetting.pfaffmanager_create_server_group
#    g.visibility_level = 4
# end unless Group.find_by_name(SiteSetting.pfaffmanager_create_server_group)
# Group.seed do |g|
#   g.name = SiteSetting.pfaffmanager_unlimited_server_group
#   g.visibility_level = 4
# end unless Group.find_by_name(SiteSetting.pfaffmanager_unlimited_server_group)
# Group.seed do |g|
#   g.name = SiteSetting.pfaffmanager_server_manager_group
#   g.visibility_level = 4
# end unless Group.find_by_name(SiteSetting.pfaffmanager_server_manager_group)
