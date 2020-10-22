import { ajax } from 'discourse/lib/ajax';
import { popupAjaxError } from 'discourse/lib/ajax-error';
import EmberObject from "@ember/object";

const Server = EmberObject.extend();

Server.reopenClass({
  server_status(model) { return JSON.parse(model)},
  dropletCreate(model) {
    console.log("dropletCreate in j/d/models/");
    console.log('model');
    console.log(model)
    let server = {
      request: 2
    };
    return ajax(`/pfaffmanager/servers/${model.id}`, {
      type: "PUT",
      data: {
        server
      }
    }).catch(popupAjaxError);
  },
  update(model) {
    console.log("update in j/d/models/");
    console.log("do:" + model.do_api_key);
    console.log(model);
    let server = {
      user_id: model.user_id,
      hostname: model.hostname,
      do_api_key: model.do_api_key,
      mg_api_key: model.mg_api_key,
      maxmind_license_key: model.maxmind_license_key,
      inventory: model.inventory,
      request: model.request,
      rebuild: model.rebuild,
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

