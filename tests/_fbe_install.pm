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
    assert_and_click('fbe_try-or-reformat_install', timeout => 10);

    # Choose to install the basic OS
    assert_and_click('fbe_reformat', timeout => 10);

    # Confirm wiping the disk
    assert_and_click('fbe_disk', timeout => 10);
    assert_and_click('fbe_disk2', timeout => 10);

    # Installation actually happens
    assert_screen('fbe_reformatting1', 10);

    # Installation complete
    # FIXME: Rather than shutting down via the ‘Power Off’ button in
    # fbe_installation_complete, use the reboot option from the Shell’s shutdown
    # dialogue. I can’t find a way to get the SUT to boot up again after using
    # the former; whereas with the latter, it reboots into the newly installed
    # system trivially. power('reset') doesn’t seem to achieve anything in the
    # former case.
    assert_and_click('fbe_installation_complete', timeout => 1800);
    assert_and_click('gnome_shutdown', timeout => 10);
}

sub test_flags {
    # Treat success as a milestone worthy of updating ‘last good’ status
    return { fatal => 1, milestone => 1 };
}

1;
