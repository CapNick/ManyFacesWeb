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

function update_order() {
    var order = [];
    $('#sortable li').each(function(e) {
        var id = $(this).attr('id');
        var label = $("#label-" + id).val();
        order.push(id + "-" + label);
    });

    $.ajax({
        method: "POST",
        url: "/faces/update_order",
        data: "order="+order
    });
}

$(document).ready(function() {
    $("#btn-sync").click(function() {
        var icon = $(this).find(".glyphicon.glyphicon-refresh");
        animateClass = "glyphicon-refresh-animate";
        icon.addClass(animateClass);
    });

    $("ul#sortable").sortable();
});
