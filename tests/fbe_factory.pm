# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'basetest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # wait for the FBE to appear
    assert_screen('fbe_welcome', 600);

    # open factory test dialog
    send_key_combo('ctrl', 'f');

    # wait for and dismiss factory dialog
    assert_and_click('fbe_factory_dialog', 'left', 10);

    # check that the FBE welcome screen reappears
    assert_screen('fbe_welcome', 10);
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
