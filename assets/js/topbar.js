import topbar from '../vendor/topbar'

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: '#29d'}, shadowColor: 'rgba(0, 0, 0, .3)'})
window.addEventListener('phx:page-loading-start', _info => topbar.show())
window.addEventListener('phx:page-loading-stop', _info => topbar.hide())
