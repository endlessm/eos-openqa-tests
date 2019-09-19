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
    sleep(4);
    assert_and_click('gdm_user_list', 'left', 10);

    # Wait for the password entry to appear.
    assert_screen('gdm_login_password', 10);

    # Enter our password and continue
    type_string(get_password());
    send_key('ret');
}

sub test_flags {
    return { fatal => 1 };
}

1;
