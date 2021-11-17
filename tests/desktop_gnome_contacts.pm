# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    check_desktop_clean();

    # Run Contacts.
    type_very_safely("gnome-contacts\n");
    assert_screen('gnome_contacts_setup', 10);

    # Go through the initial setup, selecting Local Address Book.
    # FIXME: Some improved keyboard navigation for this would be good.
    # See https://gitlab.gnome.org/GNOME/gnome-contacts/issues/130.
    send_key('tab');  # source list
    send_key('spc');  # select ‘Local Address Book’
    send_key('tab');  # ‘Quit’ button
    send_key('tab');  # ‘Done’ button
    send_key('ret');  # press the button

    # Force gnome-contacts to be maximised, as this makes the needles a little
    # simpler.
    send_key_combo('super', 'up');

    # The main window should be empty (no contacts) now.
    # Add a new contact.
    assert_and_click('gnome_contacts_main_window_empty', timeout => 10);

    type_string('Boaty McBoatface');  # name

    send_key('tab');  # e-mail type field
    send_key('tab');  # e-mail address field
    type_string('boaty@boatface.org');  # e-mail address
    send_key('tab');  # e-mail field delete button

    send_key('tab');  # phone type field
    send_key('tab');  # phone number field
    type_string('0123456789');  # phone number
    send_key('tab');  # phone field delete button

    send_key('tab');  # address type field
    send_key('tab');  # address delete button
    send_key('tab');  # field address field
    type_string('The Promenade');
    send_key('tab');  # extension
    send_key('tab');  # city
    type_string('Seaville');
    send_key('tab');  # county
    send_key('tab');  # postcode
    type_string('AB12CD');

    assert_screen('gnome_contacts_add_contact', 10);

    # FIXME: Mnemonics aren’t supported for adding a contact at the moment.
    # See https://gitlab.gnome.org/GNOME/gnome-contacts/issues/129.
    mouse_set(856, 22);  # ‘Add’ button
    mouse_click('left');

    # Restart gnome-contacts to check that storage is persistent. Click the
    # contact row once gnome-contacts has loaded so that we can view the
    # contact.
    send_key_combo('alt', 'f4');
    check_desktop_clean();

    type_very_safely("gnome-contacts\n");
    assert_and_click('gnome_contacts_main_window_one_contact', 10, 'left');

    sleep(1);

    # Check that deleting a contact works.
    mouse_set(275, 150);  # checkbox for the contact
    mouse_click('left');
    assert_and_click('gnome_contacts_main_window_one_contact_selected', timeout => 10);

    assert_screen('gnome_contacts_main_window_empty', 10);
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
