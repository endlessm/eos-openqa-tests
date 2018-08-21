use base "basetest";
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # wait for the FBE to appear
    assert_and_click "fbe_welcome", "left", 600;

    # work through FBE
    assert_and_click "fbe_try-or-reformat", "left", 10;
    assert_and_click "fbe_keyboard", "left", 10;
    assert_and_click "fbe_license", "left", 10;
    assert_and_click "fbe_complete", "left", 10;

    # desktop should be visible
    check_desktop_clean;
    save_screenshot;
}

sub test_flags {
    # Treat success as a milestone worthy of updating ‘last good’ status
    return { fatal => 1, milestone => 1 };
}

1;
