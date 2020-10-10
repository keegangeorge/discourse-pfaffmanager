import { ajax } from 'discourse/lib/ajax';
import { popupAjaxError } from 'discourse/lib/ajax-error';
import EmberObject from "@ember/object";

const Server = EmberObject.extend();

Server.reopenClass({
  update(model) {
    let server = {
      user_id: model.user_id,
      hostname: model.hostname,
      discourse_api_key: model.discourse_api_key
    };
    
    return ajax(`/pfaffmanager/servers/${model.id}`, {
      type: "PUT",
      data: {
        server
      }
    }).catch(popupAjaxError);
  }
});

export default Server;

