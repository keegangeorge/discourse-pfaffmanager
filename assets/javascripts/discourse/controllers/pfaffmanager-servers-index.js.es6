import Controller from "@ember/controller";
import EmberObject from "@ember/object";
import Server from "../models/server";

export default Controller.extend({
    actions: {
      createServerForUser() {
        Server.createServerForUser(this.model).then((result) => {
          console.log("createServer");
          console.log(this.model);
          console.log(result);
          
          if (result.errors) {
            console.log("Errors: ", errors);
          } else {
            console.log("Success");
          }
        });
      },
      
      createServer() {
        let server = {
          user_id: this.currentUser.id
        };
        
        Server.createServer(server).then(result => {
          if (result.server) {
            this.get('servers').pushObject(
              EmberObject.create(result.server)
            );
          }
        });
      }
    }
  });
  