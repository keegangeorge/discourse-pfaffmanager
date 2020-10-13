import DiscourseRoute from 'discourse/routes/discourse'

export default DiscourseRoute.extend({
  controllerName: "servers-show",
  model(params) {
    console.log('pfaffmanager-server-show.js.es6')
    return this.store.find("server", params.id);
  },
  updateServer() {
    console.log("showing in the map");
  },
  renderTemplate() {
    this.render("servers-show");
  }
});
