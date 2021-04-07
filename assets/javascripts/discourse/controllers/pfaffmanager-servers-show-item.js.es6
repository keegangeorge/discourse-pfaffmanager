import Controller from "@ember/controller";
import Server from "../models/server";

export default Controller.extend({
  unsubscribe() {
    this.messageBus.unsubscribe("/pfaffmanager-server-status/*");
  },

  subscribe() {
    this.unsubscribe();

    const server = this.server;

    this.messageBus.subscribe(
      `/pfaffmanager-server-status/${server.id}`,
      (data) => {
        server.setProperties({
          request: data.request,
          request_created_at: data.request_created_at,
          request_status: data.request_status,
          request_status_updated_at: data.request_status_updated_at,
          request_result: data.request_result,
          // ansible_running: data.ansible_running,
          //have_do_api_key: data.have_do_api_key,
          //have_mg_api_key: data.have_mg_api_key,
          active: data.active,
        });
      }
    );
  },

  actions: {
    dropletCreate() {
      Server.dropletCreate(this.server).then((result) => {
        // eslint-disable-next-line no-console
        console.log(
          "createServer in controllers/pfaffmanager-servers-show.js.es6"
        );
        // eslint-disable-next-line no-console
        console.log(this.model);
        // eslint-disable-next-line no-console
        console.log(result);
      });
    },
    upgradeServer() {
      Server.upgradeServer(this.server).then((result) => {
        // eslint-disable-next-line no-console
        console.log(
          "upgradeServer in controllers/pfaffmanager-servers-show.js.es6"
        );
        // eslint-disable-next-line no-console
        console.log(this.model);
        // eslint-disable-next-line no-console
        console.log(result);
      });
    },
    updateServer() {
      Server.updateServer(this.server).then((result) => {
        if (result.errors) {
          // eslint-disable-next-line no-console
          console.log("Errors: ", result.errors);
        } else if (result.success) {
          this.set("server", Server.create(result.server));
        }
      });
    },
  },
});
