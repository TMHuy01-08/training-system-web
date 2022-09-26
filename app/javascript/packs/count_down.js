$(document).on("turbolinks:load", function () {
  if ($(".user-exam").length > 0) {
    function timeConvert(num) {
      var minutes = num % 60;
      return minutes + ":" + "00";
    }

    function getTimeRemaining(endtime) {
      const total = Date.parse(endtime) - Date.parse(new Date());
      const seconds = Math.floor((total / 1000) % 60);
      const hours = Math.floor((total / (1000 * 60 * 60)) % 24);
      const minutes = Math.floor((total / 1000 / 60) % 60) + hours * 60;

      return {
        total,
        minutes,
        seconds,
      };
    }

    var time_left = getTimeRemaining($("#endtime").val());

    var timer2 =
      time_left.seconds < 10
        ? time_left.minutes + ":" + "0" + time_left.seconds
        : time_left.minutes + ":" + time_left.seconds;

    var exam_id = $("#exam_id").val();
    var subject_id = $("#subject_id").val();

    var interval = setInterval(function () {
      var timer = timer2.split(":");
      var minutes = parseInt(timer[0], 10);
      var seconds = parseInt(timer[1], 10);
      --seconds;
      minutes = seconds < 0 ? --minutes : minutes;
      seconds = seconds < 0 ? 59 : seconds;
      seconds = seconds < 10 ? "0" + seconds : seconds;
      $(".countdown").html(minutes + ":" + seconds);
      timer2 = minutes + ":" + seconds;

      if (
        String(window.location.pathname) !=
          `/en/subjects/${subject_id}/exams/${exam_id}` &&
        String(window.location.pathname) !=
          `/vi/subjects/${subject_id}/exams/${exam_id}`
      )
        clearInterval(interval);
      if (seconds <= 0 && minutes <= 0) clearInterval(interval);
      if (timer2 == "0:00") {
        $(".submit-exam").click();
      }
    }, 1000);
  }
});
