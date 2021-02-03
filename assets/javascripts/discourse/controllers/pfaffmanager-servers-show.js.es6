
import Controller from '@ember/controller';

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
          request_status: data.request_status,
          request_status_updated_at: data.request_status_updated_at
        });
      });
  }
});
