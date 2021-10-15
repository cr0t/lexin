import {Socket} from 'phoenix'
import {LiveSocket} from 'phoenix_live_view'

// ------------- Global UI/UX --------------

window.playAudio = function (url) {
  new Audio(url).play()
}

const queryEl = document.getElementById('form-query_field')
const resetEl = document.getElementById('form-query_reset')

resetEl.addEventListener('click', () => {
  queryEl.value = ''
  queryEl.focus()
})

// ------------- Live Socket --------------

const LANG_KEY = 'language'
const PROMPT_OPTION = 'select_language'

let hooks = {
  languageCookie: {
    mounted() {
      if (localStorage) {
        let savedLanguage = localStorage.getItem(LANG_KEY)
        let selectedLanguage = document.getElementById('form-lang').value

        // if page is opened with language param server already set it to something, and we
        // do not want to change it to saved language; only when user opens main page
        if (selectedLanguage == PROMPT_OPTION && savedLanguage !== null) {
          document.getElementById('form-lang').value = savedLanguage
        }
      }
    },
    beforeUpdate() {
      if (localStorage) {
        let langValue = document.getElementById('form-lang').value

        localStorage.setItem(LANG_KEY, langValue)
      }
    }
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute('content')

let socketParams = {
  params: {_csrf_token: csrfToken},
  hooks: hooks
}

let liveSocket = new LiveSocket('/live', Socket, socketParams)

liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
