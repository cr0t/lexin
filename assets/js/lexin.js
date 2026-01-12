import {Socket} from 'phoenix'
import {LiveSocket} from 'phoenix_live_view'

// ------------- Global UI/UX --------------

window.playAudio = function (url) {
  new Audio(url).play()
}

const queryEl = document.getElementById('search_form-query_input')
const resetEl = document.getElementById('search_form-query_reset')

if (resetEl) {
  resetEl.addEventListener('click', () => {
    queryEl.value = ''
    queryEl.focus()
  })
}

// ------------- Live Socket --------------

const LANG_SELECTOR = 'search_form-lang'
const LANG_KEY = 'language'

let hooks = {
  saveLanguage: {
    mounted() {
      if (localStorage) {
        document.getElementById(LANG_SELECTOR).addEventListener('change', e => {
          let langValue = e.target.value

          localStorage.setItem(LANG_KEY, langValue)
        })
      }
    }
  }
}

let params = {
 _csrf_token: document.querySelector("meta[name='csrf-token']").getAttribute('content'),
 lang: window.preferredLanguage() // see layouts.ex and _lang_js_utils.html.heex for details
}

let socketParams = {
  hooks: hooks,
  params: params
}

let liveSocket = new LiveSocket('/live', Socket, socketParams)

liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
