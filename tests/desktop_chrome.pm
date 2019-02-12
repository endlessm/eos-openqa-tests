# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    check_desktop_clean();

    # Run Chrome and navigate to a web page.
    type_very_safely("chrome\n");

    # Chrome isn’t installed by default; make sure it can be. Installation is
    # triggered when the user first logs in. When we launch ‘chrome’ from the
    # shell, then, we will either land in gnome-software on its search results
    # for ’chrome’ (where it will be showing the installation progress); or we
    # will open Chrome (if installation has already completed).
    # If the former, wait until installation completes (we never have to wait
    # long) and click the ‘Launch’ button from gnome-software to get to Chrome.
    if (check_screen('gnome_software_chrome_details_installed', 60)) {
        assert_and_click('gnome_software_chrome_details_installed', 'left', 10);
    }

    # Skip through the ‘Make Google Chrome the default browser’ dialogue. Do
    # this without waiting for a needle, since that’s one fewer thing to
    # maintain, and pressing enter when the dialogue isn’t there shouldn’t be a
    # problem.
    sleep(4);
    send_key('ret');

    # If Chrome is starting for the first time, it will helpfully show an
    # Adblock Plus welcome screen on top of our search results.
    if (check_screen('chrome_startup_adblock')) {
        send_key_combo('ctrl', 'w');
    }

    # We expect to see a ‘welcome’ screen the first time Chrome is started. On
    # subsequent starts, we expect to see the exploration centre; we test that
    # as the new tab, below.
    assert_screen('chrome_startup_welcome', 60);

    # Open a new tab and navigate to a deliberately boring page (which is
    # likely to always be up and unlikely to change and invalidate our needles).
    send_key_combo('ctrl', 't');
    assert_screen('chrome_new_tab', 10);

    type_string("example.com\n");
    assert_screen('chrome_example_com', 10);

    # All Endless OS systems have LibreOffice installed (unless users go out of
    # their way to remove it) so its runtime is extremely likely to be
    # installed. Chrome should use the same runtime, to minimize the chance
    # that installing it (which may happen automatically) will download a new
    # runtime. (It actually executes on the host; the runtime is not actually
    # used.)
    $self->user_console();
    assert_script_run("diff -u " .
                      "<(flatpak info org.libreoffice.LibreOffice | grep '^Runtime:') " .
                      "<(flatpak info com.google.Chrome           | grep '^Runtime:') ");
    $self->exit_user_console();

}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
