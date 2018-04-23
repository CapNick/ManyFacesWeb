// updates a staff member's 'visible' field
function toggle_visible(id) {
    $.ajax({ // generate an ajax request
        method: "POST",
        url: "/faces/toggle_visible", // invoke the toggle_visible controller action
        data: "face="+id,
        success: function() {
            var selector = '#' + id; // get the selected staff member's table row ID
            var row = $(selector);
            if (row.hasClass('default')) {
                row.attr('class', 'coloured'); // update the colour of the row appropriately
            } else {
                row.attr('class', 'default');
            }
        }
    });
}

// saves the updated staff board layout
function update_order() {
    $('#progressbar').css('display', 'block'); // displays a progress bar

    var order = [];
    $('#ordering li').each(function(e) { // for each element in the list
        if ($(this).hasClass('blank')) { // if the element is a blank div
            order.push('blank'); // push the 'blank' string into the order array
        } else {
            var id = $(this).attr('id'); // get the id of the staff member
            var label = $('#label-' + id).val(); // get any text entered into their 'label' field
            order.push(id + '-' + label); // push their id and label into the order array
        }
    });

    var dimens = $('#dimensions').val().split(' x '); // get the selected width and height

    $.ajax({ // generate an ajax request
        method: "POST",
        url: "/faces/update_order", // invoke the update_order controller action
        data: {'order': order, 'width': dimens[0], 'height': dimens[1]} // transfer the ordered list of staff and the selected dimensions
    });
}

// adds a new blank frame to the grid of staff members
function add_blank() {
    $('#ordering').prepend("" +
        "<li style='border: 1px dashed #c5c5c5'" +
        "class='blank'>" +
        "<button class='btn-delete-blank'" +
        "onclick='delete_blank(this)'>" +
        "Delete</button>" +
        "</li>"); // add the blank frame to the start of the list
    window.cutoff = window.cutoff + 1; // 'cut off' one more staff member
    update_cutoff();
}

// removes a blank frame from the grid of staff members
function delete_blank(button) {
    button.parentNode.remove(); // remove the blank frame
    window.cutoff = window.cutoff - 1; // 'cut off' one less staff member
    update_cutoff();
}

// updates the width/height of the grid of staff members
function update_dimens(dimens) {
    var xy = dimens.split(' x ');
    var x = parseInt(xy[0]); // get the selected width (in models)
    var y = parseInt(xy[1]); // get the selected height (in models)
    var width = x * 102; // get the new width of the on-screen grid
    $('#ordering').css('width', width + 'px'); // apply the new width
    var total = x * y; // get the total number of staff members displayed
    var items = $('#ordering li');
    window.cutoff = items.length - total; // get the number of staff members that will be 'cut off'
    update_cutoff();
}

// colours the frames in the grid of staff members according to whether
// they have been cut off by the selected dimensions
function update_cutoff() {
    var items = $('#ordering li');
    var shown = items.length - window.cutoff;
    items.slice(0, shown).not('.blank').css('background-color', '#f6f6f6'); // colour the frames of visible staff members light grey
    if (window.cutoff > 0) { // if any staff members are cut off
        items.slice(-window.cutoff).not('.blank').css('background-color', '#d9d9d9'); // colour the frames of invisible staff members dark grey
    }
}

$(document).ready(function() {
    $('#btn-sync').click(function() { // when the 'sync' button is clicked
        var icon = $(this).find(".glyphicon.glyphicon-refresh");
        animateClass = "glyphicon-refresh-animate";
        icon.addClass(animateClass); // rotate the 'syncing' icon
    });

    $('#ordering').sortable({ // make the grid of staff members sortable
        placeholder: "placeholder",
        stop: function(event, ui) {
            update_cutoff(); // update the colour of the displaced frames
        }
    });

    $('#progressbar').progressbar({
        value: false // display progress, but no value
    });

    $('.datatable').dataTable({ // add sorting and search functionality to the staff table
       columnDefs: [{
          targets: [7, 8, 9],
          sortable: false}] // do not allow the sorting of the last 3 columns
    });
    $('.datatable').each(function(){
        var datatable = $(this);
        var search_input = datatable.closest('.dataTables_wrapper').find('div[id$=_filter] input'); // get the search field
        search_input.attr('placeholder', 'e.g. John Smith'); // add placeholder text to the search field
        search_input.attr('id', 'search');
        search_input.addClass('form-control input-sm'); // add styling to the search field
        var length_sel = datatable.closest('.dataTables_wrapper').find('div[id$=_length] select');
        length_sel.addClass('form-control input-sm'); // add styling to the '# of items' dropdown menu
    });

    $('.btn-visible').click(function() { // when a 'visibility' button is clicked
        var span = $(this).children('span');
        var visible = span.hasClass('glyphicon-eye-open'); // check whether button icon is an open or closed eye
        var oldClass = visible ? 'glyphicon-eye-open' : 'glyphicon-eye-close';
        var newClass = visible ? 'glyphicon-eye-close' : 'glyphicon-eye-open';
        span.addClass(newClass).removeClass(oldClass); // toggle the button icon
    });

    var dimens = $('#dimensions');
    dimens.selectmenu(); // make the list of selectable dimensions a dropdown menu
    dimens.on('selectmenuchange', function() { // when a selection is made
        update_dimens($(this).val()); // update the dimensions of the on-screen grid of staff members
    });
});
