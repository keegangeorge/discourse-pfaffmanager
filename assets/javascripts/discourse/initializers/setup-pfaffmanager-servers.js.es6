import { withPluginApi } from 'discourse/lib/plugin-api';
import I18n from 'I18n';

console.log('pfaffmanager servers init');
export default {
  name: 'setup-pfaffmanager-servers',
  initialize (container) {
    withPluginApi('0.8.11', (api) => {
      const siteSettings = container.lookup('site-settings:main');
      const isNavLinkEnabled = true;
      if (isNavLinkEnabled) {
        console.log('adding navbar!');
        api.addNavigationBarItem({
          name: 'servers',
          displayName: I18n.t('pfaffmanager.server.navigation_link'),
          href: '/pfaffmanager/servers'
        });
      }
    });
  }
};
