import { ajax } from 'discourse/lib/ajax';
import { popupAjaxError } from 'discourse/lib/ajax-error';
import EmberObject from "@ember/object";

const Server = EmberObject.extend();

Server.reopenClass({
  update(model) {
    console.log("do:" + model.do_api_key);
    console.log(model);
    let server = {
      user_id: model.user_id,
      hostname: model.hostname,
      do_api_key: model.do_api_key,
      mg_api_key: model.mg_api_key,
      my_text: "this is my text",
      inventory: model.inventory,
      discourse_api_key: model.discourse_api_key
    };

    console.log(server);
    
    return ajax(`/pfaffmanager/servers/${model.id}`, {
      type: "PUT",
      data: {
        server
      }
    }).catch(popupAjaxError);
  }
});

export default Server;

