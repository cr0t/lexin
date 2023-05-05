import topbar from '../vendor/topbar'

const SHOW_DELAY = 300 // ms

topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(SHOW_DELAY))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

