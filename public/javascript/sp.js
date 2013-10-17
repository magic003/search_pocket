$(document).ready(function() {
    var showDropdown = function(event) {
        $(this).toggleClass('active');
        $('#user_session .dropdown').toggleClass('show');
        event.stopPropagation();
    };

    var hideDropdown = function(event) {
        $('#user_session').removeClass('active');
        $('#user_session .dropdown').removeClass('show');
    };

    $('html').click(hideDropdown);
    $('#user_session').click(showDropdown);

    $('#search form, #results form').submit(function(event) {
        if($.trim($('#search .searchbox').val()).length > 0) {
            return true;
        }
        return false;
    });

    $('.searchbox').focus(function(event) {
        this.selectionStart = this.selectionEnd = this.value.length;
    });

    $('.searchbox').focus();
});
