import {Socket} from 'phoenix'
import {LiveSocket} from 'phoenix_live_view'

// ------------- Global UI/UX --------------

window.playAudio = function (url) {
  new Audio(url).play()
}

const queryEl = document.getElementById('form-query_field')
const resetEl = document.getElementById('form-query_reset')

if (resetEl) {
  resetEl.addEventListener('click', () => {
    queryEl.value = ''
    queryEl.focus()
  })
}

// ------------- Live Socket --------------

const LANG_SELECTOR = 'form-lang'
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

let params = () => {
  let params = {
    _csrf_token: document.querySelector("meta[name='csrf-token']").getAttribute('content')
  }

  if (localStorage) {
    params['lang'] = localStorage.getItem(LANG_KEY)
  }

  return params
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
