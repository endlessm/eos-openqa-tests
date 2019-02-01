# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'basetest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # Wait for bootloader to appear, using a timeout explicitly lower than the
    # default because the bootloader screen will time out itself.
    # On really fast boots, the bootloader may never actually show Endless
    # branding, and will just go straight to the login screen. If so, this test
    # is trivially complete and we do not want to block for too long.
    if (check_screen('plymouth', 30)) {
        # Press Esc to show the boot progress for debugging
        send_key('esc');
    }
}

sub test_flags {
    return { fatal => 1 };
}

1;
