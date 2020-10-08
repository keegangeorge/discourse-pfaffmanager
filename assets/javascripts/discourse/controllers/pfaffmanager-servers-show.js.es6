import Controller from "@ember/controller";
import { popupAjaxError } from "discourse/lib/ajax-error";
export default Controller.extend({
  actions: {
    updateServer() {
      thisIsNotaFuction();
      console.log("update!");
    }
  }
});
