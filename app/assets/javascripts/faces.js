function toggle_visible(id) {
    $.ajax({
        method: "POST",
        url: "/faces/toggle_visible",
        data: "face="+id,
        success: function() {
            location.reload();
        }
    });
}

$(document).ready(function() {
    $("#btn-sync").click(function() {
        var icon = $(this).find(".glyphicon.glyphicon-refresh");
        animateClass = "glyphicon-refresh-animate";
        icon.addClass(animateClass);
    });

    $( "#sortable" ).sortable();
    $( "#sortable" ).disableSelection();
});
