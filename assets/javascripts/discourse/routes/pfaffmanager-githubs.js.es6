import DiscourseRoute from 'discourse/routes/discourse'

export default DiscourseRoute.extend({
  controllerName: 'githubs',

  renderTemplate () {
    this.render('githubs')
  }
})
