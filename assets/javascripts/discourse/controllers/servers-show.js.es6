import Controller from "@ember/controller";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { ajax } from 'discourse/lib/ajax';
import Server from "../models/server";

export default Controller.extend({
  actions: {
    updateServer() {
      Server.update(this.model).then((result) => {
        console.log("updateServer");
        console.log(this.model);
        console.log(result);
        
        if (result.errors) {
          console.log("Errors: ", errors);
        } else {
          console.log("Success");
        }
      });
    },
    dropletCreate(model) {
      console.log("dropletCreate in controller");
      console.log('this.model');
      console.log(this.model)
      let server = {
        request: 2
      };
      console.log(server);
      return ajax(`/pfaffmanager/servers/${this.model.id}`, {
        type: "PUT",
        data: {
          server
        }
      }).catch(popupAjaxError);
    }
  }
});
