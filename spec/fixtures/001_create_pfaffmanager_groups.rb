Group.seed do |g|
  g.name = SiteSetting.pfaffmanager_create_server_group
  g.visibility_level = Group.visibility_levels[:owners]
end
Group.seed do |g|
  g.name = SiteSetting.pfaffmanager_pro_server_group
  g.visibility_level = Group.visibility_levels[:owners]
end
Group.seed do |g|
  g.name = SiteSetting.pfaffmanager_server_manager_group
  g.visibility_level = Group.visibility_levels[:owners]
end
Group.seed do |g|
  g.name = SiteSetting.pfaffmanager_unlimited_server_group
  g.visibility_level = Group.visibility_levels[:owners]
end
Group.seed do |g|
  g.name = SiteSetting.pfaffmanager_ec2_server_group
  g.visibility_level = Group.visibility_levels[:owners]
end
Group.seed do |g|
  g.name = SiteSetting.pfaffmanager_ec2_pro_server_group
  g.visibility_level = Group.visibility_levels[:owners]
end
