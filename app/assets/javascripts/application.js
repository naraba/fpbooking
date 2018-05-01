// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks
//= require jquery
//= require moment
//= require fullcalendar
//= require fullcalendar/lang/ja
//= require_tree .

$(document).on('turbolinks:load', function() {

  set_alert = function(data) {
    if ( $('.alert')[0] ) {
      $('.alert').remove();
      $('.container').eq(1).prepend(data);
    } else {
      $('.container').eq(1).prepend(data);
    }
  };

  open_slot = function(start, end) {
    $.ajaxPrefilter(function(options, originalOptions, jqXHR) {
      var token;
      if (!options.crossDomain) {
        token = $('meta[name="csrf-token"]').attr('content');
        if (token) {
          return jqXHR.setRequestHeader('X-CSRF-Token', token);
        }
      }
    });
    $.ajax({
      type: "post",
      url: "/slots/create",
      data: {
        start: start.toISOString(),
        end: end.toISOString()
      }
    }).done(function(data) {
      alert("予約枠を登録しました");
      $('#calendar').fullCalendar('removeEvents');
      $('#calendar').fullCalendar('refetchEvents');
      set_alert(data);
    }).fail(function(data) {
      alert("予約枠の登録に失敗しました");
      set_alert(data.responseText);
    });
  };

  book_slot = function(start, end) {
    $.ajaxPrefilter(function(options, originalOptions, jqXHR) {
      var token;
      if (!options.crossDomain) {
        token = $('meta[name="csrf-token"]').attr('content');
        if (token) {
          return jqXHR.setRequestHeader('X-CSRF-Token', token);
        }
      }
    });
    $.ajax({
      type: "post",
      url: "/slots/update",
      data: {
        start: start.toISOString(),
        end: end.toISOString()
      }
    }).done(function(data) {
      alert("予約しました");
      $('#calendar').fullCalendar('removeEvents');
      $('#calendar').fullCalendar('refetchEvents');
      set_alert(data);
      $('.recent-slots').load('/slots/render_user_recent');
    }).fail(function(data) {
      alert("予約に失敗しました");
      set_alert(data.responseText);
    });
  };

  after_24hours = function(date) {
    // ugly patch(subtracting 9hours) for timezone gap
    var mod = moment(date).add(-9, 'hours').utcOffset("+0900");
    var tomorrow = moment().add(24, 'hours');
    return moment(mod).isAfter(tomorrow);
  }



  var calendar = $('#calendar').fullCalendar({
    defaultView: 'agendaWeek',
    hiddenDays: [ 0 ],
    height: "auto",
    slotDuration: '00:30:00',
    snapDuration: '00:30:00',
    minTime: '10:00:00',
    maxTime: '18:00:00',
    slotLabelFormat: 'H時',
    allDaySlot: false,
    slotEventOverlap: false,
    selectOverlap: false,
    timezone: 'Asia/Tokyo',

    displayEventTime: false,
    events: '/slots.json',

    selectable: gon.fp_signed_in, // enable only if fp signed in

    select: function(start, end) {
      if (!after_24hours(start)) return;
      if (confirm('予約枠を登録しますか')) {
        open_slot(start, end)
      }
    },

    eventClick: function(calEvent, jsEvent, view) {
      if (!after_24hours(calEvent.start)) return;
      if (!gon.fp_signed_in && "open" == calEvent.className) {
        if (confirm('予約しますか')) {
          book_slot(calEvent.start, calEvent.end);
        }
      }
    }
  });
});
