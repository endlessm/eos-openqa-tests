# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    check_desktop_clean();

    # Run the control centre.
    type_very_safely "control center\n";
    assert_screen('desktop_control_center', 10);

    # Type-ahead find for the ‘Background’ panel.
    type_string('background');
    assert_and_click('control_center_search_background', 'left', 10);

    assert_screen('control_center_background', 10);

}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
