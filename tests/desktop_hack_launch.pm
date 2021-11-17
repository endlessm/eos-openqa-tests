# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    check_desktop_clean();

    # Run Clubhouse. On first run, we should be able to see the background
    # change and the estart of the QuickStart quest.
    type_very_safely("clubhouse\n");

    # The hack first launch experience, Hack unlock

    # Click continue
    assert_and_click('clubhouse_first_launch', timeout => 10);
    # Click No
    assert_and_click('clubhouse_first_launch_1', timeout => 10);
    # Click continue
    assert_and_click('clubhouse_first_launch_2', timeout => 10);
    # Click will do
    assert_and_click('clubhouse_first_launch_3', timeout => 10);
    # close the clubhouse
    send_key_combo('alt', 'f4');

    # check that the hack icon is green
    assert_screen('desktop_hack_icon_green');
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
