use base 'basetest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # wait for bootloader to appear
    # with a timeout explicitly lower than the default because
    # the bootloader screen will timeout itself
    assert_screen('plymouth', 60);

    # Press Esc to show the boot progress for debugging
    send_key('esc');
}

sub test_flags {
    return { fatal => 1 };
}

1;
