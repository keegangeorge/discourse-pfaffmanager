import { acceptance, exists } from "discourse/tests/helpers/qunit-helpers";
import { test } from "qunit";
import { visit } from "@ember/test-helpers";

acceptance("Pfaffmanager - Index page", function (needs) {
  needs.user();

  test("show server list", async function (assert) {
    await visit("/pfaffmanager/servers");

    assert.ok($("body").length, "has a body");
    assert.ok(exists("div.pfaffmanager-index"), "has pfaffmanager index");
  });
});
