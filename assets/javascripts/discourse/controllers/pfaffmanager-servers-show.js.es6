import Controller from "@ember/controller";
import Server from "../models/server";

export default Controller.extend({
  actions: {
    dropletCreate() {
      Server.dropletCreate(this.server).then((result) => {
        console.log("createServer in controllers/pfaffmanager-servers-show.js.es6");
        console.log(this.model);
        console.log(result);
        
        if (result.errors) {
          console.log("Errors: ", errors);
        } else {
          console.log("Success");
        }
      });
    },
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
