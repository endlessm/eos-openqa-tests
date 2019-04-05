# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    check_desktop_clean();

    # Right-click on an empty bit of desktop and check the menu is correct.
    mouse_set(615, 485);
    mouse_click('right');
    assert_screen('desktop_popup_menu', 10);

    # Add App should launch gnome-software.
    mouse_set(989, 579);
    mouse_click('left');
    assert_screen('gnome_software_main_screen', 10);

    # Select LibreOffice and add it to the desktop (we assume that it’s
    # installed by default). Check the button in gnome-software changes to
    # ‘Remove from Desktop’. Quit.
    type_string('libreoffice');
    assert_and_click('gnome_software_search_libreoffice', 'left', 10);
    assert_and_click('gnome_software_libreoffice_details_installed', 'left', 60);
    assert_screen('gnome_software_libreoffice_details_installed_remove', 10);
    send_key_combo('alt', 'f4');

    # Check LibreOffice has appeared on the desktop.
    assert_screen('desktop_with_libreoffice', 10);

    # Right-click on it and check the menu is correct and can launch Calc.
    # (Then quit Calc.)
    mouse_set(446, 471);
    mouse_click('right');
    assert_screen('desktop_popup_menu_libreoffice', 10);

    mouse_set(563, 440);
    mouse_click('left');
    assert_screen('libreoffice_calc_main_window', 60);
    send_key_combo('alt', 'f4');

    # Right-click and remove LibreOffice from the desktop.
    mouse_set(446, 471);
    mouse_click('right');
    assert_screen('desktop_popup_menu_libreoffice', 10);

    mouse_set(582, 627);
    mouse_click('left');
    assert_screen('desktop_no_libreoffice', 10);

    # Right-click on an empty bit of desktop again and choose to add a website.
    mouse_set(615, 485);
    mouse_click('right');
    assert_screen('desktop_popup_menu', 10);
    mouse_set(689, 613);
    mouse_click('left');
    assert_and_click('desktop_add_website', 'left', 10);

    # Search for endlessm.com. Leave a longer timeout for matching the needle
    # because it needs to do a web request to get the description and favicon.
    # Add it to the desktop.
    type_string('endlessm.com');
    send_key('ret');
    assert_and_click('desktop_add_website_endlessm', 'left', 60);
    assert_screen('desktop_with_endlessm', 10);

    # Right-click and remove endlessm from the desktop.
    mouse_set(446, 471);
    mouse_click('right');
    assert_screen('desktop_popup_menu_endlessm', 10);

    mouse_set(582, 519);
    mouse_click('left');
    assert_screen('desktop_no_endlessm', 10);

    # Right-click on an empty bit of desktop again and choose to add a folder.
    mouse_set(615, 485);
    mouse_click('right');
    assert_screen('desktop_popup_menu', 10);
    mouse_set(689, 644);
    mouse_click('left');
    assert_screen('desktop_with_new_folder_editing', 10);

    type_string('Test Folder');
    send_key('ret');
    assert_screen('desktop_with_new_folder', 10);

    mouse_set(450, 471);
    mouse_click('left');
    assert_screen('desktop_with_new_folder_empty', 10);
    mouse_click('left');  # to dismiss the message

    # Right-click and remove the new folder from the desktop.
    mouse_set(446, 471);
    mouse_click('right');
    assert_screen('desktop_popup_menu_new_folder', 10);

    mouse_set(610, 484);
    mouse_click('left');
    assert_screen('desktop_no_new_folder', 10);
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
