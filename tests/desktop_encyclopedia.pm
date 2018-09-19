use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    check_desktop_clean();

    # The encyclopedia is installed by default on some images and not on others.
    # The list of installed apps is given as EOS_IMAGE_FLATPAK_APPS, so if the
    # encyclopedia is there, we expect to be able to run it. If not, we expect
    # that searching for it will open GNOME Software; then we can install and
    # run it.
    # Note that the encyclopedia ID varies with the locale, so we do a prefix
    # match.
    my @preinstalled_apps = split(/\s+/, get_var('EOS_IMAGE_FLATPAK_APPS', ''));
    my $expect_encyclopedia = 0;
    if (grep(/^com\.endlessm\.encyclopedia\..+$/, @preinstalled_apps)) {
        $expect_encyclopedia = 1;
    }

    # Do we expect to install it?
    if (!$expect_encyclopedia) {
        type_very_safely("gnome-software\n");
        assert_screen('gnome_software_main_screen', 10);

        # Search for encyclopedia and select the result
        type_string('encyclopedia');
        assert_and_click('gnome_software_search_encyclopedia', 'left', 10);

        # Install it
        assert_and_click('gnome_software_encyclopedia_details_uninstalled', 'left', 10);
        assert_screen('gnome_software_encyclopedia_installing', 10);

        # Wait for installation to succeed
        assert_and_click('gnome_software_encyclopedia_details_installed', 'left', 600);
        send_key_combo('alt', 'f4');
    } else {
        # Search for the encyclopedia from the desktop and launch it.
        type_very_safely("encyclopedia\n");
    }

    # Search for a random article to check searching and rendering are working.
    assert_screen('encyclopedia_startup', 10);

    type_string("blobfish\n");
    assert_and_click('encyclopedia_search_blobfish', 'left', 10);
    assert_screen('encyclopedia_article_blobfish', 10);
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
