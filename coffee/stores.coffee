import AuthStore   from 'stores/auth_store'
import FormsStore  from 'stores/forms_store'
import FormStore   from 'stores/form_store'
import EventsStore from 'stores/events_store'

module.exports =
  AuthStore: new AuthStore()
  FormsStore: new FormsStore()
  FormStore: new FormStore()
  EventsStore: new EventsStore()
