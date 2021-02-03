import Controller from '@ember/controller'
import EmberObject from '@ember/object'
import Server from '../models/server'

export default Controller.extend({
  actions: {
    dropletCreate () {
      Server.createServerForUser(this.model).then((result) => {
        if (result.errors) {
          // eslint-disable-next-line no-console
          console.log('Errors: ', result.errors)
        } else {
          // eslint-disable-next-line no-console
          console.log('Success')
        }
      })
    },

    createServer () {
      const server = {
        user_id: this.currentUser.id
      }

      Server.createServer(server).then(result => {
        if (result.server) {
          this.get('servers').pushObject(
            EmberObject.create(result.server)
          )
        }
      })
    }
  }
})
