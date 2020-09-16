import DiscourseRoute from 'discourse/routes/discourse'

export default DiscourseRoute.extend({
  controllerName: "servers-show",

  model(params) {
    return this.store.find("server", params.id);
  },

  renderTemplate() {
    this.render("servers-show");
  }
});
