import { acceptance } from "discourse/tests/helpers/qunit-helpers";

acceptance("Discourse Pfaffmanager", function (needs) {
  needs.user();

  test("viewing server page", async (assert) => {
    await visit("/pfaffmanager/servers");

    assert.ok($(".pfaffmanager-index").length, "has server list");
    // assert.ok($(".product:first-child a").length, "has a link");
  });
});
