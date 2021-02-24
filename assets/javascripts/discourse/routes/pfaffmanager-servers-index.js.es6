import DiscourseRoute from 'discourse/routes/discourse';
import Server from '../models/server';
import { A } from '@ember/array';

export default DiscourseRoute.extend({
  model () {
    return Server.listServers();
  },

  setupController (controller, model) {
    controller.set('servers', A(model.servers));
  }
});
