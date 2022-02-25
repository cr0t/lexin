import topbar from '../vendor/topbar'

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: '#29d'}, shadowColor: 'rgba(0, 0, 0, .3)'})

const SHOW_DELAY = 100 // ms

let topbarScheduled

window.addEventListener('phx:page-loading-start', _info => {
  if (!topbarScheduled) {
    topbarScheduled = setTimeout(() => topbar.show(), SHOW_DELAY)
  }
})

window.addEventListener('phx:page-loading-stop', _info => {
  clearTimeout(topbarScheduled)
  topbarScheduled = undefined
  topbar.hide()
})
