import DiscourseRoute from 'discourse/routes/discourse'

export default DiscourseRoute.extend({
  controllerName: "servers-show",
  model(params) {
    return this.store.find("server", params.id);
  },
  updateServer() {
    thisIsBogus();
    console.log("showing in the map");
  },
  renderTemplate() {
    this.render("servers-show");
  }
});
