import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import Server from "../models/server";

export default Component.extend({
  
  @discourseComputed('server.do_api_key', 'server.mg_api_key', 'loading')
  updateDisabled(doApiKey, mgApiKey, loading) {
    return (!doApiKey || !doApiKey.length) ||
      (!mgApiKey || !mgApiKey.length) ||
      loading;
  },
  
  actions: {
    dropletCreate() {
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
      });
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
