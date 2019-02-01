# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # Ensure we start from a logged in desktop, so we know the user’s session
    # (and hence session bus) has been set up correctly.
    check_desktop_clean();

    $self->user_console();
    assert_script_run('gdbus introspect --session --dest org.gnome.Shell --object-path /org/gnome/Shell | grep "interface org.gnome.Shell.AppStore"');
    assert_script_run('gdbus introspect --session --dest org.gnome.Shell --object-path /org/gnome/Shell | grep "interface org.gnome.Shell.AppLauncher"');
    $self->exit_root_console();
}

sub test_flags {
    # Treat success as a milestone worthy of updating ‘last good’ status
    return { fatal => 1, milestone => 1 };
}

1;