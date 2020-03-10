# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    check_desktop_clean();

    # This test assumes that there are two users on the system: the default user
    # (who is the administrator), and the ‘Shared Account’. It assumes we’re
    # logged in as the default user.
    #
    # It will eventually create a third (non-admin) user, and restrict their
    # parental controls. This test is then set up (in `templates`) to save its
    # state (using `STORE_HDD_1`) so that further parental controls tests can
    # depend on this state, rather than having to set up several users and
    # parental controls restrictions for themselves.
    #
    # So bear in mind when changing this test, that the final state it leaves
    # the system in is what a load of other tests expect their initial state to
    # be.

    # Run the parental controls app. It will need to be unlocked.
    type_very_safely('parental');
    send_key('ret');

    # Move the mouse somewhere where it won’t cause a tooltip.
    mouse_hide();

    # Unlock the app. The ‘Shared Account’ should be visible afterwards.
    assert_screen('malcontent_control_locked', 10);
    assert_screen_change { send_key('ret') };  # activate the Unlock button
    type_string(get_password());  # Password
    send_key('ret');

    assert_screen('malcontent_control_shared', 'left', 10);

    # Switch back to the desktop and run the control centre users panel so we
    # can add a new user. Unlock it.
    # FIXME: For some reason, searching for `users` drops the g-c-c search
    # result at the last second.
    send_key('super');
    wait_screen_change { type_very_safely("term\n") };
    type_very_safely("gnome-control-center user-accounts\n");
    #type_very_safely('users');
    #sleep(3);  # it can take a few seconds for g-c-c search provider results to appear
    #send_key('down');
    #sleep(1);
    #send_key('down');
    #sleep(1);
    #send_key('ret');
    assert_and_click('control_center_users_locked', 'left', 10);
    assert_screen('control_center_users_polkit_unlock', 10);
    type_string(get_password());  # Password
    send_key('ret');

    # Add a user. This should not present a polkit prompt.
    send_key_combo('alt', 'a');
    assert_screen('control_center_users_add_user', 10);
    wait_screen_change { type_string('Tiny Tim') };  # Username, then wait for validation
    sleep(1);
    wait_screen_change { send_key('ret') };
    sleep(1);

    # Switch back to the parental controls app. The new user should be listed.
    hold_key('alt');
    send_key('tab');
    send_key('tab');
    release_key('alt');

    # Select the new user.
    assert_and_click('malcontent_control_new_user', 'left', 10);

    # Toggle the ‘Restrict Apps’ switch on a flatpak app, disable app
    # installation, and set ‘Show Apps Suitable For’ to Everyone. There should
    # be no polkit prompts, and the changes should persist automatically.
    send_key_combo('alt', 'r');  # Open the ‘Restrict Apps’ dialogue
    assert_and_click('malcontent_control_restrict_apps', 'left', 10);
    send_key('esc');

    send_key_combo('alt', 'i');  # Disable app installation

    # Set ‘Show Apps Suitable For’, which seems to require some sleeps in order
    # to work correctly.
    sleep(1);
    send_key_combo('alt', 's');
    send_key('down');
    send_key('down');
    send_key('ret');

    sleep(2);

    assert_screen('malcontent_control_new_user_parentally_restricted', 10);

    # Switch back to the control centre and change the user’s login language so
    # that their ratings board changes from Everyone to 3+. The default language
    # which we are changing from is unset (so it defaults to `en_US` and hence
    # the ESRB ratings system).
    # This requires some sleeps for the UI to work properly (otherwise we type
    # too fast).
    send_key_combo('alt', 'tab');
    sleep(1);

    send_key_combo('alt', 'l');
    # FIXME: It would be nice to be able to do type-ahead search in this list.
    # See: https://gitlab.gnome.org/GNOME/gnome-control-center/issues/365
    assert_and_click('control_center_users_language', 'left', 10);
    type_string('Hindi');
    sleep(1);
    send_key('down');  # highlight the only result
    sleep(1);
    send_key('ret');  # select that result
    sleep(1);
    send_key_combo('alt', 's');  # submit the dialog
    sleep(2);

    send_key_combo('alt', 'tab');
    sleep(1);

    # FIXME: malcontent-control has a bug which means it doesn’t apply the
    # user’s new locale instantly. Work around that by switching to another
    # user and back. See https://gitlab.freedesktop.org/pwithnall/malcontent/-/merge_requests/44
    mouse_set(274, 100);
    mouse_click('left');
    sleep(1);
    mouse_set(773, 100);
    mouse_click('left');

    assert_and_click('malcontent_control_new_user_hindi', 'left', 10);

    # Change to the ‘Shared Account’ and back; the settings should be correctly
    # loaded and restored for both accounts.
    assert_and_click('malcontent_control_new_user', 'left', 10);
    assert_screen('malcontent_control_new_user_hindi', 10);

    # Log in a Tiny Tim on the command line and set up a few things. Since this
    # is the first time we’ve logged in as Tiny Tim, his password needs to be
    # set.
    # FIXME: Work out a way to refactor this to share code with main.pm.
    $self->user_console('tinytim', set_password => 1);
    assert_script_run('gsettings set org.gnome.desktop.notifications show-banners false', 30);
    assert_script_run('gsettings set org.gnome.desktop.session idle-delay 0', 30);
    assert_script_run('gsettings set org.gnome.desktop.background picture-options none', 30);
    assert_script_run('gsettings set org.gnome.desktop.interface enable-animations false', 30);
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
