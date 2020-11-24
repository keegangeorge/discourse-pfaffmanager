import Controller from "@ember/controller";
import Server from "../models/server";

export default Controller.extend({
  actions: {
    updateServer() {
      Server.updateServer(this.server).then((result) => {
        if (result.errors) {
          console.log("Errors: ", errors);
        } else if (result.success) {
          this.set('server', result.server);
        }
      });
    },
  }
});
