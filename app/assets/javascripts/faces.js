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
    $('#progressbar').css('display', 'block');

    var order = [];
    $('#ordering li').each(function(e) {
        if ($(this).hasClass('blank')) {
            order.push('blank');
        } else {
            var id = $(this).attr('id');
            var label = $("#label-" + id).val();
            order.push(id + "-" + label);
        }
    });

    $.ajax({
        method: "POST",
        url: "/faces/update_order",
        data: "order="+order
    });
}

function add_blank() {
    $("#ordering").prepend("" +
        "<li style='border: 1px dashed #c5c5c5'" +
        "class='blank'>" +
        "<button style='width: 50%; position: absolute; top: 35px; left: 25px'" +
        "onclick='delete_blank(this)'>" +
        "Delete</button>" +
        "</li>");
}

function delete_blank(button) {
    button.parentNode.remove();
}

$(document).ready(function() {
    $('#btn-sync').click(function() {
        var icon = $(this).find(".glyphicon.glyphicon-refresh");
        animateClass = "glyphicon-refresh-animate";
        icon.addClass(animateClass);
    });

    $('#ordering').sortable({
        placeholder: "placeholder"
    });

    $('#progressbar').progressbar({
        value: false
    });

    $('.datatable').dataTable({
       columnDefs: [{
          targets: [7, 8, 9],
          sortable: false}]
    });
    $('.datatable').each(function(){
        var datatable = $(this);
        var search_input = datatable.closest('.dataTables_wrapper').find('div[id$=_filter] input');
        search_input.attr('placeholder', 'e.g. John Smith');
        search_input.attr('id', 'search');
        search_input.addClass('form-control input-sm');
        var length_sel = datatable.closest('.dataTables_wrapper').find('div[id$=_length] select');
        length_sel.addClass('form-control input-sm');
    });
});
