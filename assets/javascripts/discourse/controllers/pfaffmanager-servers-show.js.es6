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
      `/pfaffmanager-server-status/${server.id}`, data => {
        server.setProperties({
          request_status: data.request_status,
          request_status_updated_at: data.request_status_updated_at
        });
      });
  },
  
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
          this.set('server', Server.create(result.server));
        }
      });
    },
  }
});
