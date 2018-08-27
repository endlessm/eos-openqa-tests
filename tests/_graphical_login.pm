use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # Wait for the login screen to appear
    assert_and_click('gdm_user_list', 'left', 600);

    # Enter our password and continue
    type_string('123');
    send_key('ret');
}

sub test_flags {
    return { fatal => 1 };
}

1;
