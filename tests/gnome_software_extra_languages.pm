# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    check_desktop_clean();
    type_very_safely("gnome-software\n");
    assert_screen('gnome_software_main_screen', 600);

    $self->root_console();
    assert_script_run('flatpak config --system --set extra-languages pt_BR', 30);
    assert_script_run('pkill -f gnome-software', 30);
    $self->exit_root_console();

    check_desktop_clean();
    type_very_safely("gnome-software\n");
    assert_screen('gnome_software_main_screen', 600);

    # Search for anima to match 'animais' and 'animals'
    type_string('anima');
    assert_screen('gnome_software_extra_languages', 600);
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
