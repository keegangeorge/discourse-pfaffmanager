export default function() {
  this.route("pfaffmanager", function() {
    this.route("actions", function() {
      this.route("show", { path: "/:id" });
    });
    this.route("servers", function() {
      this.route("show", { path: "/:id" });
    });
    this.route("githubs", function() {
      this.route("show", { path: "/:id" });
    });
  });
};
