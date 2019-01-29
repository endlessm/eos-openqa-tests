# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'basetest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # wait for the FBE to appear; choose "Indonesian"
    assert_and_click('fbe_welcome_choose_indonesian', 'left', 600);

    # wait for the "Next" button to change to Indonesian and click it
    assert_and_click('fbe_welcome_indonesian', 'left', 10);

    # work through FBE
    if (get_var('LIVE')) {
        assert_and_click('fbe_try-or-reformat_indonesian', 'left', 10);
    }

    assert_and_click('fbe_keyboard_indonesian', 'left', 10);
    assert_and_click('fbe_license_indonesian', 'left', 10);

    if (!get_var('LIVE')) {
        # FIXME: as and when the timezone page appears for this test, take new
        # screenshots. It is less likely to appear because the extra time spent
        # changing language improves the odds that Geoclue has worked out where we
        # are.

        # If the timezone couldn’t be found automatically,
        # select an arbitrary one.
        if (check_screen('fbe_timezone2', 10)) {
            type_string('Jakarta');  # I hear it’s a pretty cool place
            send_key('down');
            send_key('ret');
        }

        # The timezone screen is only shown if the timezone could not be
        # detected automatically.
        if (check_screen('fbe_timezone', 10)) {
            assert_and_click('fbe_timezone', 'left', 10);
        }

        assert_and_click('fbe_accounts_indonesian', 'left', 10);

        assert_screen('fbe_about_you_indonesian', 10);
        type_string('Test');  # Username
        send_key('tab');
        type_string(' ');  # Tick the password box
        assert_and_click('fbe_about_you2_indonesian', 'left', 10);

        assert_screen('fbe_password_indonesian', 10);
        type_string('123');  # Password
        send_key('tab');  # Skip over ‘Show password’ tickbox
        send_key('tab');
        type_string('123');  # Confirmation
        send_key('tab');
        type_string('123');  # Hint
        assert_and_click('fbe_password2_indonesian', 'left', 10);
    }

    if (get_var('LIVE')) {
        assert_and_click('fbe_complete_live', 'left', 10);

        # desktop should be visible
        assert_screen("desktop_live_indonesian", 60);
    } else {
        assert_and_click('fbe_complete_install_indonesian', 'left', 10);

        # desktop should be visible
        assert_screen("desktop_freshly_installed_indonesian", 60);
    }

    save_screenshot();
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
