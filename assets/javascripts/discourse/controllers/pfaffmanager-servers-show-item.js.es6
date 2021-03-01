import Controller from '@ember/controller';
import Server from '../models/server';
import discourseComputed from 'discourse-common/utils/decorators';
import { computed } from '@ember/object';

export default Controller.extend({

  unsubscribe () {
    this.messageBus.unsubscribe('/pfaffmanager-server-status/*');
  },

  subscribe () {
    this.unsubscribe();

    const server = this.server;

    this.messageBus.subscribe(
      `/pfaffmanager-server-status/${server.id}`, data => {
        server.setProperties({
          request: data.request,
          request_created_at: data.request_created_at,
          request_status: data.request_status,
          request_status_updated_at: data.request_status_updated_at,
          ansible_running: data.ansible_running
        });
      });
  },

  actions: {
    dropletCreate () {
      Server.dropletCreate(this.server).then((result) => {
      // eslint-disable-next-line no-console
        console.log('createServer in controllers/pfaffmanager-servers-show.js.es6');
        // eslint-disable-next-line no-console
        console.log(this.model);
        // eslint-disable-next-line no-console
        console.log(result);

        if (result.errors) {
          console.log('Errors: ', errors);
        } else {
          console.log('Success');
        }
      });
    },
    upgradeServer () {
      Server.upgradeServer(this.server).then((result) => {
      // eslint-disable-next-line no-console
        console.log('upgradeServer in controllers/pfaffmanager-servers-show.js.es6');
        // eslint-disable-next-line no-console
        console.log(this.model);
        // eslint-disable-next-line no-console
        console.log(result);

        if (result.errors) {
          // eslint-disable-next-line no-console
          console.log('Errors: ', errors);
        } else {
          // eslint-disable-next-line no-console
          console.log('Success');
        }
      });
    },
    updateServer () {
      Server.updateServer(this.server).then((result) => {
        if (result.errors) {
          // eslint-disable-next-line no-console
          console.log('Errors: ', errors);
        } else if (result.success) {
          this.set('server', Server.create(result.server));
        }
      });
    }
  }
});
