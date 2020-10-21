import Controller from "@ember/controller";
import { popupAjaxError } from 'discourse/lib/ajax-error';
import { ajax } from 'discourse/lib/ajax';

export default Controller.extend({
    actions: {
      updateServer() {
        console.log("updateServer in controllers/servers.js.es6");
        console.log(this.model);
        Server.update(this.model).then((result) => {
          console.log(result);
          
          if (result.errors) {
            console.log("Errors: ", errors);
          } else {
            console.log("Success");
          }
        });
      },
      createServer() {
        console.log("createServer in controllers/servers.js.es6");
        console.log(this.currentUser);
        console.log(this.currentUser.id);
        let server = {
            user_id: this.currentUser.id
          };
          console.log(server);
          return ajax(`/pfaffmanager/servers`, {
            type: "POST",
            data: {
              server
            }
          }).catch(popupAjaxError);
      }
    }
  });
  