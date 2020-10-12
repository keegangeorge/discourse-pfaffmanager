import Controller from "@ember/controller";
import { popupAjaxError } from "discourse/lib/ajax-error";
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
    }
  }
});
