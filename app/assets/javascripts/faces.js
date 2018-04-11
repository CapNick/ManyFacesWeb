function toggle_visible(id) {
    $.ajax({
        method: "POST",
        url: "/faces/toggle_visible",
        data: "face="+id,
        success: function() {
            var selector = '#' + id;
            var row = $(selector);
            if (row.hasClass('default')) {
                row.attr('class', 'coloured');
            } else {
                row.attr('class', 'default');
            }
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

    var dimens = $('#dimensions').val().split(' x ');

    $.ajax({
        method: "POST",
        url: "/faces/update_order",
        data: {'order': order, 'width': dimens[0], 'height': dimens[1]}
    });
}

function add_blank() {
    $('#ordering').prepend("" +
        "<li style='border: 1px dashed #c5c5c5'" +
        "class='blank'>" +
        "<button style='width: 50%; position: absolute; top: 35px; left: 25px'" +
        "onclick='delete_blank(this)'>" +
        "Delete</button>" +
        "</li>");
    window.cutoff = window.cutoff + 1;
    update_cutoff();
}

function delete_blank(button) {
    button.parentNode.remove();
    window.cutoff = window.cutoff - 1;
    update_cutoff();
}

function update_dimens(dimens) {
    var xy = dimens.split(' x ');
    var x = parseInt(xy[0]);
    var y = parseInt(xy[1]);
    var width = x * 102;
    $('#ordering').css('width', width + 'px');
    var total = x * y;
    var items = $('#ordering li');
    window.cutoff = items.length - total;
    update_cutoff();
}

function update_cutoff() {
    var items = $('#ordering li');
    // remove colour from face no longer being cut-off
    var shown = items.length - window.cutoff;
    items.slice(0, shown).not('.blank').css('background-color', '#f6f6f6');
    // colour new cut-off face
    if (window.cutoff > 0) {
        items.slice(-window.cutoff).not('.blank').css('background-color', '#d9d9d9');
    }
}

$(document).ready(function() {
    $('#btn-sync').click(function() {
        var icon = $(this).find(".glyphicon.glyphicon-refresh");
        animateClass = "glyphicon-refresh-animate";
        icon.addClass(animateClass);
    });

    $('#ordering').sortable({
        placeholder: "placeholder",
        stop: function(event, ui) {
            update_cutoff();
        }
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

    $('.btn-visible').click(function() {
        var span = $(this).children('span');
        var visible = span.hasClass('glyphicon-eye-open');
        var oldClass = visible ? 'glyphicon-eye-open' : 'glyphicon-eye-close';
        var newClass = visible ? 'glyphicon-eye-close' : 'glyphicon-eye-open';
        span.addClass(newClass).removeClass(oldClass);
    });

    var dimens = $('#dimensions');
    dimens.selectmenu();
    dimens.on('selectmenuchange', function() {
        update_dimens($(this).val());
    });
});
