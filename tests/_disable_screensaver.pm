use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # Disable the screensaver idle timeout permanently. It can be
    # re-enabled as needed for specific tests.
    $self->user_console();
    assert_script_run('gsettings set org.gnome.desktop.session idle-delay 0', 30);
    $self->exit_user_console();
}

sub test_flags {
    return { fatal => 1 };
}

1;
