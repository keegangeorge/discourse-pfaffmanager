import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import Server from "../models/server";

export default Component.extend({
  
  @discourseComputed('server.do_api_key', 'server.mg_api_key', 'server.hostname', 'loading')
  updateDisabled(doApiKey, mgApiKey, hostname, loading) {
    return ( ( !doApiKey || ( doApiKey != 'testing' && doApiKey.length < 64) ) &&
      (!mgApiKey || ( mgApiKey != 'testing' && mgApiKey.length < 36)) &&
      !hostname ) ||
      loading;
  },

  @discourseComputed('server.encrypted_do_api_key', 'server.encrypted_mg_api_key', 'server.installed_version', 'server.hostname', 'loading')
  createDropletDisabled(doApiKey, mgApiKey, installedVersion, hostname, loading) {
    console.log('hostname');
    console.log(hostname);
    return (!doApiKey || !mgApiKey || installedVersion || hostname.match(/unconfigured/g)) ||
      loading;
  },
  actions: {
    dropletCreate() {
      this.set('loading', true);
      Server.dropletCreate(this.server).then((result) => {
      // eslint-disable-next-line no-console
      console.log("createServer in controllers/pfaffmanager-servers-show.js.es6");
      // eslint-disable-next-line no-console
      console.log(this.model);
      // eslint-disable-next-line no-console
      console.log(result);
        
        if (result.errors) {
          console.log("Errors: ", errors);
        } else {
          console.log("Success");
        }
      }).finally(() => this.set('loading', false));
    },
    
    upgradeServer() {
      this.set('loading', true);
      
      Server.upgradeServer(this.server).then((result) => {
      // eslint-disable-next-line no-console
      console.log("upgradeServer in controllers/pfaffmanager-servers-show.js.es6");
      // eslint-disable-next-line no-console
      console.log(this.model);
      // eslint-disable-next-line no-console
      console.log(result);
          
        if (result.errors) {
          // eslint-disable-next-line no-console
          console.log("Errors: ", errors);
        } else {
          // eslint-disable-next-line no-console
          console.log("Success");
        }
      }).finally(() => this.set('loading', false));
    },
    
    updateServer() {
      this.set('loading', true);
      Server.updateServer(this.server).then((result) => {
        if (result.errors) {
          // eslint-disable-next-line no-console
          console.log("Errors: ", errors);
        } else if (result.success) {
          this.set('server', Server.create(result.server));
        }
      }).finally(() => this.set('loading', false));
    },
  }
});
