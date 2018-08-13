use base "basetest";
use strict;
use testapi;

# high-level 'type this string extremely safely and rather slow'
# function whose specific implementation may vary
sub type_very_safely {
    my $string = shift;
    type_string($string, wait_screen_change => 1, max_interval => 1);
    wait_still_screen 5;
}

sub run {
    my $self = shift;

    # wait for bootloader to appear
    # with a timeout explicitly lower than the default because
    # the bootloader screen will timeout itself
    assert_screen "plymouth", 6000;

    # press enter to boot right away
    send_key "esc";

    # wait for the desktop to appear
    assert_and_click "fbe_welcome", "left", 60000;

    # work through FBE
    assert_and_click "fbe_try-or-reformat", "left", 1000;
    assert_and_click "fbe_keyboard", "left", 1000;
    assert_and_click "fbe_license", "left", 1000;
    assert_and_click "fbe_complete", "left", 1000;

    # desktop should be visible
    assert_screen "desktop", 6000;
    save_screenshot;

    # run the terminal
    type_very_safely "term\n";
    save_screenshot;
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
