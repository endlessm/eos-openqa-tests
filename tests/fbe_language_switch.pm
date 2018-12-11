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

    assert_and_click('fbe_keyboard_indonesian', 'left', 10);
    assert_screen('fbe_license_indonesian', 10);

    # TODO: click through all subsequent pages
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
