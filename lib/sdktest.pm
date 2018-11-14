package sdktest;
use base 'installedtest';
use testapi;
use utils;

sub add_nightly_sdk_repo {
    my $self = shift;
    my $repo = 'http://endlessm.github.io/eos-knowledge-lib/eos-sdk-nightly.flatpakrepo';

    $self->disable_polkit_policy('org.freedesktop.Flatpak.configure-remote',
                                 '90-flatpak-configure-remote.rules');
    $self->user_console();
    assert_script_run('flatpak remote-add --from eos-sdk-nightly ' . $repo);
    $self->exit_user_console();
    $self->remove_polkit_policy('90-flatpak-configure-remote.rules');
}

sub install_app {
    my $self = shift;
    my $app_id = shift;
    my $run_with_nightly_sdk = shift;
    my $runtime_id = 'com.endlessm.apps.Platform//master';

    $self->user_console();
    assert_script_run('flatpak install -y eos-apps ' . $app_id, 1800);
    if (!$run_with_nightly_sdk) {
        $self->exit_user_console();
    }

    if ($run_with_nightly_sdk) {
        assert_script_run('flatpak install -y eos-sdk-nightly ' . $runtime_id, 1800);
        $self->exit_user_console();

        check_desktop_clean();
        type_very_safely("gnome-terminal\n");
        assert_screen('desktop_terminal', 5);
        type_string("flatpak run --runtime=$runtime_id $app_id &>/dev/null &\n");
    }
    # We want to be sure that after switching back to the desktop, the cursor
    # is not over a part of the screen that changes its behavior when the cursor
    # is over.
    mouse_hide();
}

1;
