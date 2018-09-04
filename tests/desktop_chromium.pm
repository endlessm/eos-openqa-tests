use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    check_desktop_clean();

    # Run Chromium and navigate to a web page. On first run, we should be able
    # to see the Exploration Center (possibly after closing the Adblock tab).
    type_very_safely("chromium\n");

    # If Chromium is starting for the first time, it will helpfully show an
    # Adblock Plus welcome screen on top of our search results.
    if (check_screen('chromium_startup_adblock')) {
        send_key_combo('ctrl', 'w');
    }

    assert_screen('chromium_startup_exploration_center', 10);

    # Open a new tab and navigate to a deliberately boring page (which is
    # likely to always be up and unlikely to change and invalidate our needles).
    send_key_combo('ctrl', 't');
    assert_screen('chromium_new_tab', 10);

    type_string("example.com\n");
    assert_screen('chromium_example_com', 10);
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
