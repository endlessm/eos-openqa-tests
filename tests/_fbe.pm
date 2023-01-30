# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'basetest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # wait for the FBE to appear
    assert_and_click('fbe_welcome', timeout => 600);

    # work through FBE
    if (get_var('LIVE')) {
        assert_and_click('fbe_try-or-reformat', timeout => 10);
    }

    assert_and_click('fbe_keyboard', timeout => 10);
    assert_and_click('fbe_license', timeout => 10);

    if (!get_var('LIVE')) {
        # FIXME: Does this come after the timezone?
        if (get_var('VERSION') !~ m/^eos3./) {
            assert_and_click('fbe_privacy', timeout => 10);
        }

        # If the timezone couldn’t be found automatically,
        # select an arbitrary one.
        #
        # FIXME: if we wait here without clicking anything, and if the network
        # and the Mozilla Location Service are both up, a timezone should
        # eventually be detected. This feature was added in
        # https://phabricator.endlessm.com/T23524.
        if (check_screen('fbe_timezone2', 10)) {
            type_string('Berlin');  # I hear it’s a pretty cool place
            send_key('down');
            send_key('ret');
        }

        # The timezone screen is only shown if the timezone could not be
        # detected automatically.
        if (!check_screen('fbe_accounts', 0.5)) {
            assert_and_click('fbe_timezone', timeout => 10);
        }

        assert_and_click('fbe_accounts', timeout => 10);

        assert_screen('fbe_about_you', 10);
        type_string('Test');  # Full Name
        send_key('tab');
        if (get_var('VERSION') !~ m/^eos3./) {
            send_key('tab');  # Username in EOS4+
            send_key('tab');
        }
        type_string(' ');  # Tick the password box
        assert_and_click('fbe_about_you2', timeout => 10);

        my $password = get_password();

        assert_screen('fbe_password', 10);
        type_string($password);  # Password
        send_key('tab');
        type_string($password);  # Confirmation
        send_key('tab');
        type_string($password);  # Hint

        send_key('tab');  # ‘Previous’ button
        send_key('tab');  # ‘Next’ button
        send_key('ret');
    }

    if (get_var('LIVE')) {
        assert_and_click('fbe_complete_live', timeout => 10);
    } else {
        assert_and_click('fbe_complete_install', timeout => 10);
    }

    # Desktop should be visible. Don’t use check_desktop_clean() here, because
    # we want to only check the minimum amount possible for the FBE to pass.
    # By this point, we won’t have cleared the desktop background.
    assert_screen('desktop_bottom_bar_only', 60);
    save_screenshot();
}

sub test_flags {
    # Treat success as a milestone worthy of updating ‘last good’ status
    return { fatal => 1, milestone => 1 };
}

1;
