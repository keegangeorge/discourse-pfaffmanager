import DiscourseRoute from 'discourse/routes/discourse';

export default DiscourseRoute.extend({
  activate () {
    this._super(...arguments);

    this.messageBus.subscribe(`/pfaffmanager-server-status/${self.id}`,
      this.server_message
    );
  },
  deactivate () {
    this.messageBus.unsubscribe(`/pfaffmanager-server-status/${self.id}`);
  }
});
