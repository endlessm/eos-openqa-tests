use base 'basetest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # wait for the FBE to appear
    assert_and_click('fbe_welcome', 'left', 600);

    # work through FBE
    if (get_var('LIVE')) {
        assert_and_click('fbe_try-or-reformat', 'left', 10);
    }

    assert_and_click('fbe_keyboard', 'left', 10);
    assert_and_click('fbe_license', 'left', 10);

    if (!get_var('LIVE')) {
        # If the timezone couldn’t be found automatically,
        # select an arbitrary one.
        if (check_screen('fbe_timezone2', 10)) {
            type_string('Berlin');  # I hear it’s a pretty cool place
            send_key('down');
            send_key('ret');
        }

        # The timezone screen is only shown if the timezone could not be
        # detected automatically.
        if (check_screen('fbe_timezone', 10)) {
            assert_and_click('fbe_timezone', 'left', 10);
        }

        assert_and_click('fbe_accounts', 'left', 10);

        assert_screen('fbe_about_you', 10);
        type_string('Test');  # Username
        send_key('tab');
        type_string(' ');  # Tick the password box
        assert_and_click('fbe_about_you2', 'left', 10);

        assert_screen('fbe_password', 10);
        type_string('123');  # Password
        send_key('tab');  # Skip over ‘Show password’ tickbox
        send_key('tab');
        type_string('123');  # Confirmation
        send_key('tab');
        type_string('123');  # Hint
        assert_and_click('fbe_password2', 'left', 10);
    }

    if (get_var('LIVE')) {
        assert_and_click('fbe_complete_live', 'left', 10);
    } else {
        assert_and_click('fbe_complete_install', 'left', 10);
    }

    # desktop should be visible
    check_desktop_clean();
    save_screenshot();
}

sub test_flags {
    # Treat success as a milestone worthy of updating ‘last good’ status
    return { fatal => 1, milestone => 1 };
}

1;
