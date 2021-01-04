Group.seed do |g|
  g.name = SiteSettings.pfaffmanager_create_server_group
    g.visibility_level = Group.visibility_levels[:owners]
end
Group.seed do |g|
  g.name = SiteSettings.pfaffmanager_pro_server_group
    g.visibility_level = Group.visibility_levels[:owners]
end
Group.seed do |g|
  g.name = SiteSettings.pfaffmanager_server_manager_group
    g.visibility_level = Group.visibility_levels[:owners]
end
Group.seed do |g|
  g.name = SiteSettings.pfaffmanager_unlimited_server_group
    g.visibility_level = Group.visibility_levels[:owners]
end
