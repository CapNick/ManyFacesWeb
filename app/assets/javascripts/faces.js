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
