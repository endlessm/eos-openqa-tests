# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    check_desktop_clean();

    # Run Yelp; it should show our customised main page.
    type_very_safely("yelp\n");
    assert_screen('yelp_main_page', 10);

    send_key_combo('alt', 'f4');

    # Search for a help topic, and results should be shown by a search provider.
    type_very_safely('add user');
    assert_screen('yelp_search_provider_results', 10);

    send_key('esc');

    # Try pressing F1 while in Nautilus. Yelp should be launched.
    type_very_safely("nautilus\n");
    assert_screen('nautilus_home', 10);

    send_key('f1');
    assert_screen('yelp_nautilus_page', 10);
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
