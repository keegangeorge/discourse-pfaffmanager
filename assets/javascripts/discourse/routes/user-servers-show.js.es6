import DiscourseRoute from 'discourse/routes/discourse';
import Server from '../models/server';

export default DiscourseRoute.extend({
  model(params) {
    return Server.findServer(params.id);
  },
  
  setupController(controller, model) {
    controller.set('server', Server.create(model.server));
    controller.subscribe();
  }
});
