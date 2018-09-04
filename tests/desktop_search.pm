use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    check_desktop_clean();

    # Run a search in the Shell, look at the results, then run the first one
    # (which in this case should always be the browser).
    type_very_safely('search terms');
    assert_screen('desktop_search', 10);
    send_key('ret');

    # If Chromium is starting for the first time, it will helpfully show an
    # Adblock Plus welcome screen on top of our search results.
    if (check_screen('chromium_startup_adblock')) {
        send_key_combo('ctrl', 'w');
    }

    assert_screen('browser_search', 10);
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
