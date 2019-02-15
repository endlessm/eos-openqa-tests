# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    check_desktop_clean();

    # As per parental_controls_setup.pm, we start out with several users and
    # some parental controls configured. We start out logged in as the
    # administrator, search for a non-child-friendly game (‘Cow’s Revenge’),
    # install it and uninstall it. We then switch users to the Shared Account,
    # which is not an administrator but has no parental OARS restrictions. We
    # repeat the Cow’s Revenge test, but expecting that installation should
    # trigger an auth dialogue this time. We then repeat the test with the Tiny
    # Tim account, who is not an administrator *and* has parental OARS
    # restrictions. Tiny Tim should not be able to find Cow’s Revenge, or
    # install it.

    # Run gnome-software.
    type_very_safely("gnome-software\n");
    assert_screen('gnome_software_main_screen', 10);

    # Search for Cow’s Revenge. It should appear, since we’re logged in as an
    # administrator. Cow’s Revenge has some ‘intense’ OARS ratings, but a fairly
    # small download size, so shouldn’t make the test take too long.
    type_string('Cow\'s Revenge');
    assert_and_click('gnome_software_search_cows_revenge', 'left', 10);

    # Install it. We don’t expect an auth dialogue.
    assert_and_click('gnome_software_cows_revenge_details_uninstalled', 'left', 10);
    assert_screen('gnome_software_cows_revenge_installing', 10);

    # Wait for installation to succeed.
    assert_screen('gnome_software_cows_revenge_details_installed', 600);
    send_key_combo('alt', 'f4');

    # Uninstall it again.
    $self->uninstall_flatpak_app('com.github.dariasteam.cowsrevenge');

    # Switch user to the Shared Account.
    $self->switch_user('shared', '');

    # Run gnome-software.
    type_very_safely("gnome-software\n");
    assert_screen('gnome_software_main_screen', 10);

    # Search for Cow’s Revenge. It should still appear, since we’re logged in as
    # the shared user, who has no OARS restrictions set.
    type_string('Cow\'s Revenge');
    assert_and_click('gnome_software_search_cows_revenge', 'left', 10);

    # Install it. We expect an auth dialogue this time. Don’t bother checking
    # for the `gnome_software_cows_revenge_installing` screen, as it often
    # completes too quickly after the auth dialogue.
    assert_and_click('gnome_software_cows_revenge_details_uninstalled', 'left', 10);
    assert_screen('gnome_software_cows_revenge_installing_auth', 10);
    type_string('123');  # Password
    send_key('ret');

    # Wait for installation to succeed.
    assert_screen('gnome_software_cows_revenge_details_installed', 600);
    send_key_combo('alt', 'f4');

    # Uninstall it again.
    $self->uninstall_flatpak_app('com.github.dariasteam.cowsrevenge');

    # Switch user to Tiny Tim. Since this is the first time we’ve logged in as
    # Tiny Tim, his password needs to be set.
    $self->switch_user('tiny', '', '123');

    # Run gnome-software.
    type_very_safely("gnome-software\n");
    assert_screen('gnome_software_main_screen', 10);

    # Search for Cow’s Revenge. It should not appear, since we’re logged in as Tiny
    # Tim, who has restrictive OARS settings.
    type_string('Cow\'s Revenge');
    assert_screen('gnome_software_search_no_results', 10);
    send_key_combo('alt', 'f4');

    # Try installing Cow’s Revenge from the command line. This should also fail.
    check_desktop_clean();
    type_very_safely("gnome-terminal\n");
    assert_screen('desktop_terminal', 5);
    type_string("gnome-software --install system/flatpak/flathub/desktop/com.github.dariasteam.cowsrevenge/stable\n");

    # FIXME: Currently it brings up a polkit authentication dialogue, which is
    # potentially a hangover from the eos-google-chrome-installer (TODO), but
    # potentially also an attempt to install Cow's Revenge. Dismiss the auth
    # dialogue so we can see the gnome-software error message and check it.
    # I can’t reproduce this on a VM.
    sleep(5);
    send_key('esc');  # dismiss the polkit dialogue
    sleep(2);
    send_key_combo('alt', 'tab');  # switch from the terminal to gnome-software since it doesn’t steal focus properly

    assert_screen('gnome_software_unable_to_install_cows_revenge', 10);
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
