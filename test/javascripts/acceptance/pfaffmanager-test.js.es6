import { acceptance } from "helpers/qunit-helpers";

acceptance("Pfaffmanager", { loggedIn: true });

test("Pfaffmanager works", async (assert) => {
  await visit("/pfaffmanager/servers");

  assert.ok(false, "it loads the server list");
});
