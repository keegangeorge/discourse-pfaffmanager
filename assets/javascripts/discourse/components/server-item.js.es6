import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import Server from "../models/server";
//import SiteSetting from "admin/models/site-setting";
// import { bufferedProperty } from "discourse/mixins/buffered-content";

export default Component.extend({
  @discourseComputed("server.do_api_key", "server.mg_api_key", "server.hostname", "loading")
  updateDisabled(doApiKey, mgApiKey, hostname, loading) {
    return ( ( !doApiKey || ( doApiKey != "testing" && doApiKey.length < 64) ) &&
      (!mgApiKey || ( mgApiKey != "testing" && mgApiKey.length < 36))) ||
      loading;
  },
  @discourseComputed("server.request_status")
  haveVM(status) {
    console.log("haveVM");
    console.log(status && status.length>0);
    return (status && status.length > 0);
  },
  @discourseComputed("server.install_type")
  isDropletInstallType(install_type) {
    return this.siteSettings.pfaffmanager_droplet_install_types.split("|").includes(install_type);
  },

  @discourseComputed("loading")
  updateDisabledServer(loading) {
    console.log("updateDisabledServer");
    return ( loading);
  },

  @discourseComputed("server.encrypted_do_api_key",
  "server.encrypted_mg_api_key",
  "server.hostname", "originalHostname", "loading")
   createDropletDisabled(doApiKey, mgApiKey,
    hostname, originalHostname, loading) {
      this.set("originalHostname", originalHostname ? originalHostname : hostname);
      console.log("hostname");
      console.log(!hostname.match(/ /g));
      // console.log(originalHostname);
      if (originalHostname && hostname != originalHostname && mgApiKey && doApiKey) {
        this.set("updateReason", "Save hostname to continue");
        } else {
        this.set("updateReason", "Required parameters must be saved before installation");
      }
      // CONFUSED: this causes hostnameValid to get modified twice on render. Why?
      //this.set("hostnameValid", ("hostname".match(/unconfigured/g)) ? false : true );

      return (!doApiKey || !mgApiKey
      || hostname.match(/ /g))
      || (originalHostname && hostname != originalHostname);
  },
  actions: {
    dropletCreate() {
      this.set("loading", true);
      console.log("dropletCreate action in controllers/pfaffmanager-servers-item.js.es6");
      Server.dropletCreate(this.server).then((result) => {
      // eslint-disable-next-line no-console
      console.log("did the dropletCreate in controllers/pfaffmanager-servers-item.js.es6");
      // eslint-disable-next-line no-console
      console.log(this.model);
      // eslint-disable-next-line no-console
      console.log("this is the result");
      console.log(result);

        if (result.errors) {
          console.log("Errors: ", errors);
        } else {
          console.log("Success");
        }
      }).finally(() => this.set("loading", false));
    },

    upgradeServer() {
      this.set("loading", true);

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
      }).finally(() => this.set("loading", false));
    },

    updateServer() {
      this.set("loading", true);
      Server.updateServer(this.server).then((result) => {
        if (result.errors) {
          // eslint-disable-next-line no-console
          console.log("Errors: ", errors);
        } else if (result.success) {
          this.set("server", Server.create(result.server));
          this.set("originalHostname", this.server.hostname);
        }
      }).finally(() => this.set("loading", false));
    },
  }
});
