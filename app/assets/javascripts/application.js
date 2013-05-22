// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery.ui.all
//= require jquery.ui.datepicker-ru
//= require jquery.moodular
//= require krutilka
//= require kickstart/kickstart
//= require common
//= require rails.validations
//= require dataTables/jquery.dataTables
//= require date.format


$(document).ready(function () {
    jQuery.fn.reverseEach = (function () {
        var list = jQuery([1]);
        return function (c) {
            var el, i = this.length;
            try {
                while (i-- > 0 && (el = list[0] = this[i]) && c.call(list, i, el) !== false);
            }
            catch (e) {
                delete list[0];
                throw e;
            }
            delete list[0];
            return this.get(0);
        };
    }());
//    $(':password').showPassword();
});

