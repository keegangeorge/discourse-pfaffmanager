import Controller from "@ember/controller";

export default Controller.extend({
    actions: {
      updateServer() {
        Server.update(this.model).then((result) => {
          console.log("updateServer");
          console.log(this.model);
          console.log(result);
          
          if (result.errors) {
            console.log("Errors: ", errors);
          } else {
            console.log("Success");
          }
        });
      },
      createServerForUser() {
        Server.createServerForUser(this.model).then((result) => {
          console.log("createServer");
          console.log(this.model);
          console.log(result);
          
          if (result.errors) {
            console.log("Errors: ", errors);
          } else {
            console.log("Success");
          }
        });
      }
    }
  });
  