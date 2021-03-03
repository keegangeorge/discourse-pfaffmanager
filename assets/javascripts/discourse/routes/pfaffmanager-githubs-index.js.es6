import DiscourseRoute from "discourse/routes/discourse";

export default DiscourseRoute.extend({
  controllerName: "githubs-index",

  model() {
    return this.store.findAll("github");
  },

  renderTemplate() {
    this.render("githubs-index");
  },
});
