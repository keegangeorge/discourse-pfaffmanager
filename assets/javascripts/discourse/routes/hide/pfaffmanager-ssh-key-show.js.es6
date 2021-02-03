// export default DiscourseRoute.extend({
//   controllerName: "server",

//   renderTemplate() {
//     this.render("key");
//   }
// });

import DiscourseRoute from 'discourse/routes/discourse'
import Server from '../models/server'

export default DiscourseRoute.extend({
  model (params) {
    console.log(params)
    return Server.findServer(params.id)
  }
})
