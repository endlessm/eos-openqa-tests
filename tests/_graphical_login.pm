# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # Wait for the login screen to appear, then give it 2s to settle. The
    # final match area in any needle
    # tagged as ‘gdm_user_list’ is guaranteed to be the ‘Test’ administrator
    # user.
    assert_screen('gdm_user_list', 600);
    # FIXME: Increase the gdm timeout from 4 to 8 as it is guessed that the
    # gdm is taking a while to react to mouse clicks. There might be actual
    # issue in gdm itself and should be investigated before resetting the timeout.
    sleep(8);
    assert_and_click('gdm_user_list', 'left', 10);

    # Wait for the password entry to appear.
    assert_screen('gdm_login_password', 10);
    sleep(8);

    # FIXME: Click out of and back into the password box, in case it’s not
    # focused properly. This should really be investigated in gdm itself.
    mouse_set(150, 415);
    mouse_click('left');
    sleep(1);
    mouse_set(450, 415);
    mouse_click('left');
    sleep(2);

    # Enter our password and continue
    type_very_safely(get_password());
    assert_screen_change { send_key('ret') };
}

sub test_flags {
    return { fatal => 1 };
}

1;
