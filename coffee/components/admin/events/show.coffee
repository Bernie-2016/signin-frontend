import React             from 'react'
import Fluxxor           from 'fluxxor'
import { History, Link } from 'react-router'
import { Row, Col }      from 'react-bootstrap'
import Loader            from 'react-loader'
import _                 from 'lodash'
import moment            from 'moment'
import Client            from 'client'

module.exports = React.createClass
  displayName: 'AdminEvent'

  mixins: [Fluxxor.FluxMixin(React), Fluxxor.StoreWatchMixin('AuthStore', 'EventsStore'), History]

  getStateFromFlux: ->
    store = @props.flux.store('EventsStore')
    evt = _.find(store.events, id: parseInt(@props.params.id)) || {}

    {
      name: evt.name
      date: moment(evt.date)
      slug: evt.slug
      color: evt.color
      earlyAccess: evt.early_access
      fields: evt.questions || []
      signupsCount: evt.signups_count
      loaded: store.loaded
      error: store.error
      destroyedId: store.destroyedId
    }

  deleteEvent: (e) ->
    e.preventDefault()
    if confirm('Are you sure you want to delete this event? This action cannot be undone.')
      @props.flux.actions.admin.events.destroy(
        authToken: @props.flux.store('AuthStore').authToken
        id: parseInt(@props.params.id)
      )

  downloadCsv: (e) ->
    e.preventDefault()
    Client.get "/events/#{@props.params.id}/csv", @props.flux.store('AuthStore').authToken, {}, (response) ->
      hiddenElement = document.createElement('a')
      hiddenElement.href = 'data:attachment/csv,' + encodeURI(response)
      hiddenElement.target = '_blank'
      hiddenElement.download = 'signups.csv'
      hiddenElement.click()

  componentDidMount: ->
    @props.flux.actions.admin.events.load(@props.flux.store('AuthStore').authToken) unless @state.loaded

  componentDidUpdate: ->
    @history.pushState(null, '/admin/events') if @state.destroyedId

  render: ->
    <Loader loaded={@state.loaded} top='35%'>
      <h1>{@state.name}</h1>
      <h3>{@state.date.format('MM/DD/YYYY')}</h3>
      {if @state.earlyAccess
        <h3 style={color: @state.color}>Event Color</h3>
      }
      <h4>Signups: {@state.signupsCount}</h4>
      <p>
        <strong>Form URL: </strong><a href="https://signin.berniesanders.com/#{@state.slug}" target='_blank'>https://signin.berniesanders.com/{@state.slug}</a>
      </p>
      <p>
        <a href='#' onClick={@downloadCsv}>Download CSV</a>
      </p>
      
      {if _.isEmpty(_.reject(@state.fields, type: 'gotv'))
        <h4>No custom fields</h4>
      else
        <h4>Fields:</h4>
      }
      {for field in @state.fields when field.type isnt 'gotv' && field.type isnt 'select'
        <div key={field.id}>
          <p>
            <strong>Title:</strong> {field.title}
          </p>
          <p>
            <strong>Type:</strong> {field.type}
          </p>
          <hr />
        </div>
      }
      {if @state.earlyAccess
        <div>
          <h4>Early Access Shifts:</h4>
          <h5>Staging Cities: {((_.find(@state.fields, type: 'select') || {}).choices || []).join(', ')}</h5>
          {for field in @state.fields when field.type is 'gotv'
            <div key={field.id}>
              <p>
                <strong>Shift:</strong> {field.title}
              </p>
              <hr />
            </div>
          }
        </div>
      }
      <Link to={"/admin/events/#{@props.params.id}/edit"} className='btn'>
        Edit
      </Link>
      <a href='#' className='btn' onClick={@deleteEvent}>
        Delete
      </a>
    </Loader>
