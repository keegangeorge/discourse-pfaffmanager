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
  
  updateServer(data) {
    console.log("update in j/d/models/");
    console.log("do:" + data.do_api_key);
    console.log(data);
    let server = {
      user_id: data.user_id,
      hostname: data.hostname,
      do_api_key: data.do_api_key,
      mg_api_key: data.mg_api_key,
      maxmind_license_key: data.maxmind_license_key,
      request: data.request,
      rebuild: data.rebuild,
      discourse_api_key: data.discourse_api_key
    };
    console.log(server);
    return ajax(`/pfaffmanager/servers/${data.id}`, {
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

