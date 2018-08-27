use base "installedtest";
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    check_desktop_clean;

    # run the terminal
    type_very_safely "term\n";
    assert_screen('desktop_terminal', 10);
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
