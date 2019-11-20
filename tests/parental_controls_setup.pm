# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # Coordinates for the bottom of the scroll bar trough on the users panel,
    # which we use a few times to scroll down to see all the parental controls.
    my $scroll_bottom_x = 1016;
    my $scroll_bottom_y = 640;

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

    # Run the control centre users panel. The current (admin) user should not
    # have any parental controls visible.
    type_very_safely('parental');
    send_key('down');
    send_key('ret');

    # Move the mouse somewhere where it won’t cause a tooltip.
    mouse_hide();

    # Switch to the ‘Shared Account’ account. This should not cause a polkit
    # prompt. The parental controls should be visible but insensitive, because
    # the capplet is locked.
    assert_and_click('control_center_users_locked', 'left', 10);
    assert_and_click('control_center_users_shared_locked', 'left', 10);

    # Unlock the panel.
    assert_screen('control_center_users_polkit_unlock', 10);
    type_string(get_password());  # Password
    send_key('ret');

    # Scroll down so we can see the parental controls better. They should be
    # visible and sensitive for the ‘Shared Account’. Switch to the admin
    # account; the parental controls should still be hidden for them.
    mouse_set($scroll_bottom_x, $scroll_bottom_y);
    mouse_click('left');

    assert_and_click('control_center_users_shared_unlocked', 'left', 10);
    assert_screen('control_center_users_unlocked', 10);

    # Add a user. This should not present a polkit prompt.
    send_key_combo('alt', 'a');
    assert_screen('control_center_users_add_user', 10);
    type_string('Tiny Tim');  # Username
    send_key('ret');

    # Once the new user’s added, the control center should show their details
    # immediately. The parental controls should be visible and sensitive.
    assert_screen('control_center_users_new_user_added', 10);

    # Scroll down so we can see the parental controls properly.
    mouse_set($scroll_bottom_x, $scroll_bottom_y);
    mouse_click('left');

    # Toggle the ‘Restrict Apps’ switch on a flatpak app, disable app
    # installation, and set ‘Show Apps Suitable For’ to 7+. There should be no
    # polkit prompts, and if we wait 2s (longer than the 1s timeout g-c-c waits
    # before saving changes), the changes should persist.
    mouse_set(785, 429);
    mouse_click('left');

    send_key_combo('alt', 'i');  # Disable app installation

    # Set ‘Show Apps Suitable For’, which seems to require some sleeps in order
    # to work correctly.
    sleep(1);
    send_key_combo('alt', 's');
    send_key('down');
    send_key('down');
    send_key('ret');

    sleep(2);

    assert_screen('control_center_users_new_user_parentally_restricted', 10);

    # Change the user’s login language so that their ratings board changes from
    # 7+ to 7. The default language which we are changing from is unset (so,
    # the IARC ratings system).
    # This requires some sleeps for the UI to work properly (otherwise we type
    # too fast).
    send_key_combo('alt', 'l');
    # FIXME: It would be nice to be able to do type-ahead search in this list.
    # See: https://gitlab.gnome.org/GNOME/gnome-control-center/issues/365
    assert_and_click('control_center_users_language', 'left', 10);
    type_string('English United Kingdom');
    sleep(1);
    send_key('up');  # highlight the only result
    sleep(1);
    send_key('ret');  # select that result
    sleep(1);
    send_key_combo('alt', 's');  # submit the dialog
    sleep(2);

    assert_and_click('control_center_users_new_user_added_en_gb', 'left', 10);

    # Change to the ‘Shared Account’ and back; the settings should be correctly
    # loaded and restored for both accounts.
    assert_screen('control_center_users_shared_unlocked_with_new_user', 10);
    mouse_set(905, 104);
    mouse_click('left');
    assert_screen('control_center_users_new_user_added_en_gb', 10);
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
