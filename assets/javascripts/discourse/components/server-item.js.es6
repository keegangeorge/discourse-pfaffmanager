import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import Server from "../models/server";
//import SiteSetting from "admin/models/site-setting";
// import { bufferedProperty } from "discourse/mixins/buffered-content";

export default Component.extend({
  @discourseComputed(
    "server.do_api_key",
    "server.mg_api_key",
    "server.hostname",
    "loading"
  )
  updateDisabled(doApiKey, mgApiKey, hostname, loading) {
    return (
      ((!doApiKey || (doApiKey !== "testing" && doApiKey.length < 64)) &&
        (!mgApiKey || (mgApiKey !== "testing" && mgApiKey.length < 36))) ||
      loading
    );
  },
  @discourseComputed("server.hostname")
  hostnameValid(hostname) {
    return !hostname.match(/ /g);
  },
  @discourseComputed("server.have_vm")
  haveVM(status) {
    return status;
  },
  @discourseComputed("server.have_vm")
  needVM(status) {
    return !status;
  },
  @discourseComputed("server.install_type", "server.do_install_types")
  isDropletInstallType(installType, doInstallTypes) {
    // eslint-disable-next-line no-console
    console.log("isDropletInstallType");
    return doInstallTypes.includes(installType);
  },
  @discourseComputed("server.install_type", "server.ec2_install_types")
  isEc2InstallType(installType, ec2InstallTypes) {
    // eslint-disable-next-line no-console
    console.log("isEc2Install");
    return ec2InstallTypes.includes(installType);
  },
  @discourseComputed("loading", "server.ansible_running")
  updateDisabledServer(loading, ansibleRunning) {
    // eslint-disable-next-line no-console
    console.log("server-item.updateDisabledServer--ansibleRunning");
    // eslint-disable-next-line no-console
    console.log(ansibleRunning);
    return loading || ansibleRunning;
  },

  @discourseComputed("server.install_type", "server.have_do_api_key")
  canCreateVM(installType, haveDoApiKey) {
    // eslint-disable-next-line no-console
    console.log("canCreateVM");
    // eslint-disable-next-line no-console
    console.log(haveDoApiKey);
    // eslint-disable-next-line no-console
    console.log(installType);
    return haveDoApiKey || installType === "ec2";
  },

  @discourseComputed(
    "server.install_type",
    "server.have_do_api_key",
    "server.have_mg_api_key",
    "server.hostname",
    "loading"
  )
  createDropletDisabled(
    installType,
    haveDoApiKey,
    haveMgApiKey,
    hostname,
    loading
  ) {
    return (
      !(haveDoApiKey || installType === "ec2") ||
      !haveMgApiKey ||
      hostname.match(/ /g) ||
      loading
    );
  },

  @discourseComputed("server.ansible_running", "loading")
  upgradeServerDisabled(ansibleRunning, loading) {
    // eslint-disable-next-line no-console
    console.log("server-item.updateServerDisabled");
    // eslint-disable-next-line no-console
    console.log(ansibleRunning);
    if (ansibleRunning) {
      this.set("updateReason", "upgradeServerDisabled--Ansible Task Running");
    } else {
      this.set(
        "updateReason",
        "upgradeServerDisabled--server model update in progress"
      );
    }
    return loading || ansibleRunning;
  },

  markDirty() {
    this.set("dirty", true);
  },
  actions: {
    dropletCreate() {
      this.set("loading", true);
      // eslint-disable-next-line no-console
      console.log(
        "dropletCreate action in controllers/pfaffmanager-servers-item.js.es6"
      );
      Server.dropletCreate(this.server).then((result) => {
        // eslint-disable-next-line no-console
        console.log(
          "did the dropletCreate in controllers/pfaffmanager-servers-item.js.es6"
        );
        // eslint-disable-next-line no-console
        console.log(this);
        // eslint-disable-next-line no-console
        console.log("this is the result");
        // eslint-disable-next-line no-console
        console.log(result);
        // eslint-disable-next-line no-console
        console.log("the last action is");
        // eslint-disable-next-line no-console
        console.log(result.server.last_action);
        // eslint-disable-next-line no-console
        console.log("this is the server result");
        // eslint-disable-next-line no-console
        console.log(result.server);
        this.set("server", result.server);
        // eslint-disable-next-line no-console
        console.log(this);

        if (result.errors) {
          // eslint-disable-next-line no-console
        } else {
          // eslint-disable-next-line no-console
          console.log("Success");
        }
      }); // TODO: make sure that ansible always registers something AND that it gets to message bus
    },
    updateDropletSize(value) {
      this.set("loading", true);
      this.set("server.droplet_size", value);
      Server.updateServer(this.server)
        .then((result) => {
          if (result.errors) {
            // eslint-disable-next-line no-console
            console.log("Errors: ", result.errors);
          } else if (result.success) {
            // eslint-disable-next-line no-console
            console.log("updateServer.success");
            // eslint-disable-next-line no-console
            console.log(result);
            this.set("server", Server.create(result.server));
            // eslint-disable-next-line no-console
            console.log("updateServer.success complete");
          }
        })
        .finally(() => this.set("loading", false));
    },

    upgradeServer() {
      this.set("loading", true);

      Server.upgradeServer(this.server)
        .then((result) => {
          // eslint-disable-next-line no-console
          console.log(
            "upgradeServer in controllers/pfaffmanager-servers-show.js.es6"
          );
          // eslint-disable-next-line no-console
          console.log(this.model);
          // eslint-disable-next-line no-console
          console.log(result);

          if (result.errors) {
            // eslint-disable-next-line no-console
            console.log("Errors: ", result.errors);
          } else {
            // eslint-disable-next-line no-console
            console.log("Success");
          }
        })
        .finally(() => this.set("loading", false));
    },
    updateServer() {
      this.set("loading", true);
      // see update in j/d/models/server.js.es6
      Server.updateServer(this.server)
        .then((result) => {
          if (result.errors) {
            // eslint-disable-next-line no-console
            console.log("Errors: ", result.errors);
          } else if (result.success) {
            // eslint-disable-next-line no-console
            console.log("updateServer.success");
            // eslint-disable-next-line no-console
            console.log(result);
            this.set("server", Server.create(result.server));
            // eslint-disable-next-line no-console
            console.log("updateServer.success complete");
          }
        })
        .finally(() => this.set("loading", false));
    },
  },
});
