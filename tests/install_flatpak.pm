use base "installedtest";
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    check_desktop_clean;

    # Run gnome-software. Wait and ignore the initial ‘Installing Google Chrome’
    # page if we’ve raced with that — it’s done as soon as gnome-software is run
    # for the first time on a new installation.
    type_very_safely("gnome-software\n");
    if (check_screen('gnome_software_installing_chrome', 10)) {
        assert_screen('gnome_software_chrome_details_installed', 600);
        send_key_combo('alt', 'f4');
        sleep(1);
        type_very_safely("gnome-software\n");
    }

    assert_screen('gnome_software_main_screen', 10);

    # Search for VLC and select the result
    type_string("vlc");
    assert_and_click('gnome_software_search_vlc', 'left', 10);

    # Install it
    assert_and_click('gnome_software_vlc_details_uninstalled', 'left', 10);
    assert_screen('gnome_software_vlc_installing', 10);

    # Check installation has succeeded
    assert_and_click('gnome_software_vlc_details_installed', 'left', 600);
    assert_screen('desktop_vlc', 60);
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
