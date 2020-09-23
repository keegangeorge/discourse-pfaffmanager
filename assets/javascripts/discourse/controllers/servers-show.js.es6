import Controller from "@ember/controller";
import { popupAjaxError } from "discourse/lib/ajax-error";
export default Controller.extend({
  init() {
    this._super(...arguments);
    console.log("init this.");
  },


  actions: {
    wtf() {
      console.log(this);
    },

    createServer() {
      if (this.get("model.id") === undefined) {
        const serverID = this.get("model.firstObject.id");
        this.set("model.id", serverID);
      }
      console.log(this.get('model'));
      this.get("model")
        .save()
        .then(() => {
          this.transitionToRoute("pfaffmanager.servers");
        })
        .catch(popupAjaxError);
    },
    
    updateServer() {
      console.log(this);
      this.get("model")
        .update()
        .catch(data =>
          bootbox.alert(data.jqXHR.responseJSON.errors.join("\n"))
        );
    }
  }});
