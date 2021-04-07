import Controller from "@ember/controller";

export default Controller.extend({
  unsubscribe() {
    this.messageBus.unsubscribe("/pfaffmanager-server-status/*");
  },

  subscribe() {
    this.unsubscribe();

    const server = this.server;

    this.messageBus.subscribe(
      // `/pfaffmanager-server-status/${server.id}`, data => {
      `/pfaffmanager-server-status/${server.id}`,
      (data) => {
        server.setProperties({
          request_created_at: data.request_created_at,
          request_status: data.request_status,
          request_status_updated_at: data.request_status_updated_at,
          // ansible_running: data.ansible_running,
          // have_do_api_key: data.have_do_api_key,
          // have_mg_api_key: data.have_mg_api_key,
          request_result: data.request_result,
          active: data.active,
        });
      }
    );
  },
});
