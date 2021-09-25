window.playAudio = function (url) {
  new Audio(url).play()
}

const queryEl = document.getElementById('form-query_field')
const resetEl = document.getElementById('form-query_reset')

resetEl.addEventListener('click', () => {
  queryEl.value = ''
  queryEl.focus()
})
