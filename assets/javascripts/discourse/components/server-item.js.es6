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
  @discourseComputed("server.have_vm")
  haveVM(status) {
    console.log("haveVM");
    console.log(status);
    return (status);
  },
  @discourseComputed("server.install_type", "server.do_install_types")
  isDropletInstallType(installType, doInstallTypes) {
    console.log("isDropletInstallType")
    return doInstallTypes.includes(installType);
  },
  @discourseComputed("server.install_type", "server.ec2_install_types")
  isEc2InstallType(installType, ec2InstallTypes) {
    console.log("isEc2Install")
    return ec2InstallTypes.includes(installType);
  },
  @discourseComputed("loading", "server.ansible_running")
  updateDisabledServer(loading, ansibleRunning) {
    console.log("updateDisabledServer--ansible");
    console.log(ansibleRunning);
    return ( loading || ansibleRunning);
  },

  @discourseComputed("server.install_type", "server.have_do_api_key")
  canCreateVM(installType, haveDoApiKey) {
    console.log('canCreateVM');
    console.log(haveDoApiKey);
    console.log(installType);
    return ((haveDoApiKey || installType == 'ec2'));
  },

  @discourseComputed("server.install_type", "server.have_do_api_key",
  "server.have_mg_api_key",
  "server.hostname", "originalHostname", "loading")
   createDropletDisabled(installType, haveDoApiKey, haveMgApiKey,
    hostname, originalHostname, loading) {
      this.set("originalHostname", originalHostname ? originalHostname : hostname);
      console.log("hostname");
      console.log(!hostname.match(/ /g));
      // console.log(originalHostname);
      if (originalHostname && hostname != originalHostname && haveMgApiKey && haveDoApiKey) {
        this.set("updateReason", "Save hostname to continue");
        } else {
        this.set("updateReason", "Required parameters must be saved before installation");
      }
      // CONFUSED: this causes hostnameValid to get modified twice on render. Why?
      //this.set("hostnameValid", ("hostname".match(/unconfigured/g)) ? false : true );

      return (!(haveDoApiKey || installType == 'ec2') || !haveMgApiKey
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
      }); // TODO: make sure that ansible always registers something AND that it gets to message bus
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
      console.log("Server-item update server");
      this.set("loading", true);
      // see update in j/d/models/server.js.es6
      Server.updateServer(this.server).then((result) => {
        if (result.errors) {
          // eslint-disable-next-line no-console
          console.log("Errors: ", errors);
        } else if (result.success) {
          console.log("updateServer.success");
          console.log(result);
          this.set("server", Server.create(result.server));
          this.set("originalHostname", this.server.hostname);
          console.log("updateServer.success complete");
        }
      }).finally(() => this.set("loading", false));
    },
  }
});
