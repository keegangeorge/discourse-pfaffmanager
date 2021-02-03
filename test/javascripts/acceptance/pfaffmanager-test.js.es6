import { acceptance } from 'helpers/qunit-helpers'

acceptance('Pfaffmanager', { loggedIn: true })

test('Pfaffmanager works', async assert => {
  await visit('/admin/plugins/pfaffmanager')

  assert.ok(false, 'it shows the Pfaffmanager button')
})
