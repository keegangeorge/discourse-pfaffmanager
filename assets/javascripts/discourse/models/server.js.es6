import { ajax } from 'discourse/lib/ajax';
import { popupAjaxError } from 'discourse/lib/ajax-error';
import EmberObject from "@ember/object";
import discourseComputed from "discourse-common/utils/decorators";
import { computed } from "@ember/object";


const Server = EmberObject.extend();

Server.reopenClass({
  server_status(model) { return JSON.parse(model)},
  @discourseComputed("encrypted_do_api_key")
  canCreateDroplet(do_api_key) {
    return "sdflkjsdflkjsdflksdflksdf";
  },
  banana(){
    return "banana";
  },
  dropletCreate(model) {
    // eslint-disable-next-line no-console
    console.log("dropletCreate in the model j/d/models/server.js.es6");
    // eslint-disable-next-line no-console
    console.log(model);
    return ajax(`/pfaffmanager/install/${model.id}`, {
      type: "PUT",
    }).catch(popupAjaxError);
  },
  
  upgradeServer(model) {
    // eslint-disable-next-line no-console
    console.log("upgrade in j/d/models/");
    // eslint-disable-next-line no-console
    console.log(model);
    return ajax(`/pfaffmanager/upgrade/${model.id}.json`, {
      type: "POST"
    }).catch(popupAjaxError);
  },  
  updateServer(model) {
    // eslint-disable-next-line no-console
    console.log("update in j/d/models/server.js.es6");
    // eslint-disable-next-line no-console
    console.log(model);
    let server = {
      user_id: model.user_id,
      hostname: model.hostname,
      do_api_key: model.do_api_key,
      mg_api_key: model.mg_api_key,
      maxmind_license_key: model.maxmind_license_key
    };
    // eslint-disable-next-line no-console
    console.log(server);
    return ajax(`/pfaffmanager/servers/${model.id}`, {
      type: "PUT",
      data: {
        server
      }
    }).catch(popupAjaxError);
  },

  listServers() {
    return ajax(`/pfaffmanager/servers`, {
      type: "GET"
    }).catch(popupAjaxError);
  },
  
  createServer(server) {
    return ajax(`/pfaffmanager/servers`, {
      type: "POST",
      data: {
        server
      }
    }).catch(popupAjaxError);
  },
  
  findServer(serverId) {
    return ajax(`/pfaffmanager/servers/${serverId}`, {
      type: "GET"
    }).catch(popupAjaxError);
  }
});

export default Server;

