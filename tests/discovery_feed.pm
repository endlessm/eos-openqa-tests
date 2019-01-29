# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    check_desktop_clean();

    # Click on the discovery feed arrow to activate it.
    mouse_set(512, 20);  # screen is 1024 × 768
    mouse_click('left');
    assert_screen('desktop_discovery_feed', 10);

    # FIXME: Working out how to test the discovery feed is fairly tricky, since
    # it’s so dynamic. For the moment, be satisfied with it just appearing and
    # disappearing again when we press escape.
    send_key('esc');
    check_desktop_clean();
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
