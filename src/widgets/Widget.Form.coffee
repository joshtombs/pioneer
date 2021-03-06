Promise = require('bluebird')
_       = require('lodash')

class @Widget.Form extends @Widget
  root: 'form'

  submitSelector: (node) ->
    if node?
      if _.isString(node)
        @find(node)
      else
        Promise.resolve(node)
    else
      @find('[type="submit"]')

  submitForm: =>
    @submitSelector().then (el) -> el.click()

  submitWith: (values) =>
    @fillAll(values)
    .then(@submitForm)

  select: (opts) ->
    if opts.text? and opts.value?
      throw new Error('You may only have one select by attribute.')
    else if opts.text? or _.isString(opts)
      @_selectByText(opts.text)
    else if opts.value?
      @_selectByValue(opts.value)
    else
      throw new Error('You must provide something to select by.')

  _selectByText: (text) ->
    @find({text: text}).then (el) ->
      el.click()

  _selectByValue: (value) ->
    @find("option[value=\"#{value}\"]").then (el) ->
      el.click()

  fillAll: (values) ->
    @_map Object.keys(values), (f) => @fill({
      selector: @_name(f)
      value: values[f]
    })

  readAll: ->
    _readAll = (f) =>
      @read(@_name(f)).then (v) -> [f, v]

    @_map(@fields, _readAll).then (read) ->
      _.object(read)

  _name: (name) ->
    "[name='#{name}']"

  _type: (type) ->
    "[type='#{type}']"

  _map: (collection, callback) ->
    results = []
    _reduce = (p, f, i) ->
      p.then ->
        callback(f, i).then (v) -> results.push(v)
    _.reduce(collection, _reduce, Driver.promise.fulfilled())
      .then -> results

