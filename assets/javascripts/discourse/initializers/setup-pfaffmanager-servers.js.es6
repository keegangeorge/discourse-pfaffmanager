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
      if (self.Discourse.currentUser) {
        const newServerMinutes = 30;
        const maxServerLinks = 3;
        const servers = self.Discourse.currentUser.servers.sort(function (
          a,
          b
        ) {
          return b.id - a.id;
        });
        servers.length =
          servers.length > maxServerLinks ? maxServerLinks : servers.length;

        if (servers.length > 0) {
          const headerLinks = [];
          servers.filter(Boolean).map((server) => {
            const isNewServer =
              (Date.now() - new Date(server.created_at)) / 1000 / 60 <
              newServerMinutes;
            const newClass = isNewServer ? ".new-server" : "";
            const linkHref = `/pfaffmanager/servers/${server.id}`;
            const linkTitle = `click to configure server ${server.id}`;
            const linkText = `${server.hostname}`;
            const deviceClass = server.hostname.match(/ /g)
              ? ".unconfigured"
              : "";
            const anchorAttributes = {
              title: linkTitle,
              href: linkHref,
            };
            headerLinks.push(
              h(
                `li.headerLink${deviceClass}${newClass}`,
                h("a", anchorAttributes, linkText)
              )
            );
          });
          api.decorateWidget("header-buttons:before", (helper) => {
            return helper.h("ul.pfaffmanager-header-links", headerLinks);
          });
        }
      }
    });
  },
};
