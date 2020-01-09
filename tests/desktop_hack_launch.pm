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

    # Click on FtH
    assert_and_click('clubhouse_first_launch', 'left', 10);
    # Solve the puzzle
    assert_screen('hack_unlock_flipped');
    mouse_set(555, 493);
    mouse_click();
    mouse_set(498, 541);
    mouse_click();
    mouse_set(493, 585);
    mouse_click();
    # Flip back
    assert_and_click('clubhouse_flip_back', 'left', 10);

    # wait for the clubhouse
    assert_screen('clubhouse_launch');
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
