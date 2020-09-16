import DiscourseRoute from 'discourse/routes/discourse'

export default DiscourseRoute.extend({
  controllerName: "servers-index",

  model(params) {
    return this.store.findAll("server");
  },

  renderTemplate() {
    this.render("servers-index");
  }
});
