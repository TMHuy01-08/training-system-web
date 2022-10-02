import Rails from "@rails/ujs";
import Turbolinks from "turbolinks";
import * as ActiveStorage from "@rails/activestorage";
import "channels";
import "chartkick/chart.js";
require("jquery");
import "bootstrap";
import "../stylesheets/application";
require("@nathanvda/cocoon");
require("packs/count_down");
require("packs/back_reload");
require("packs/create_answer_handle");

Rails.start();
Turbolinks.start();
ActiveStorage.start();
global.toastr = require("toastr");
toastr.options = {
  closeButton: false,
  debug: false,
  newestOnTop: false,
  progressBar: true,
  positionClass: "toast-top-right",
  preventDuplicates: false,
  onclick: null,
  showDuration: "300",
  hideDuration: "3000",
  timeOut: "2000",
  extendedTimeOut: "1000",
  showEasing: "swing",
  hideEasing: "linear",
  showMethod: "fadeIn",
  hideMethod: "fadeOut",
};
