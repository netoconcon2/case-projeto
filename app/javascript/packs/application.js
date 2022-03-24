// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//= require country_state_select

require("@rails/ujs").start()
require("@rails/activestorage").start()
require("channels")
require('@client-side-validations/client-side-validations')
require('../plugins/simple-form.bootstrap4')

import Trix from 'plugins/trix-editor';

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
// External imports
import "@hotwired/turbo-rails"
import "bootstrap";
import "controllers";
import flatpickr from 'flatpickr';
import Inputmask from "inputmask";
import "inputmask/dist/jquery.inputmask";
import initSelect2 from "plugins/select2";
import Swal from "sweetalert2";
import tooltips from 'plugins/tooltip';
window.Swal = Swal;

document.addEventListener('turbo:load', () => {
  initSelect2();
  tooltips();
  // document.querySelectorAll('a:not([data-turbo]),form:not([data-turbo])').forEach(el => {
  //   el.setAttribute('data-turbo', false)
  // })
});


import "controllers"
