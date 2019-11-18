# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    check_desktop_clean();

    # Undo the fine work of _disable_background.pm so that we can actually test
    # the background (and icon grid) in this specific test.
    $self->user_console();
    assert_script_run('gsettings reset org.gnome.desktop.background picture-options', 30);
    $self->exit_user_console();

    # How does it look?
    assert_screen('desktop_freshly_installed_with_background', 10);
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;
