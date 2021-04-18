import { withPluginApi } from "discourse/lib/plugin-api";
import I18n from "I18n";
import { h } from "virtual-dom";

export default {
  name: "setup-pfaffmanager-servers",
  initialize(container) {
    withPluginApi("0.8.11", (api) => {
      const siteSettings = container.lookup("site-settings:main");
      // TODO: do not display link if not logged in
      const isNavLinkEnabled = siteSettings.pfaffmanager_enabled;
      if (isNavLinkEnabled) {
        api.addNavigationBarItem({
          name: "servers",
          displayName: I18n.t("pfaffmanager.server.navigation_link"),
          href: "/pfaffmanager/servers",
        });
      }
      console.log("widget thing");
      if (self.Discourse.currentUser) {
        const servers = self.Discourse.currentUser.servers;
        if (servers.length > 0) {
          const headerLinks = [];
          servers.filter(Boolean).map((server) => {
            console.log("in map");
            console.log(server.id);
            const linkHref = `/pfaffmanager/servers/${server.id}`;
            const linkTitle = `title manage server ${server.id}`;
            const linkText = `${server.hostname}`;
            const icon = server.hostname;
            const deviceClass = ".unconfigured";
            const anchorAttributes = {
              title: linkTitle,
              href: linkHref,
            };
            console.log(`got anchor ${linkHref}`);
            headerLinks.push(
              h(
                `li.headerLink${deviceClass}`,
                h("a", anchorAttributes, linkText)
              )
            );
          });
          console.log("about to decorate");
          api.decorateWidget("header-buttons:before", (helper) => {
            return helper.h("ul.pfaffmanager-header-links", headerLinks);
          });
          console.log("the links");
          console.log(headerLinks);
        }
      }
    });
  },
};
