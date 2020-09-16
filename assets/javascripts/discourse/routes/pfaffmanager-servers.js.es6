import DiscourseRoute from 'discourse/routes/discourse'

export default DiscourseRoute.extend({
  controllerName: "servers",

  renderTemplate() {
    this.render("servers");
  }
});
