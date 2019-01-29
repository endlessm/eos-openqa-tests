# vi: set shiftwidth=4 tabstop=4 expandtab:
package sdktest;
use base 'installedtest';
use testapi;
use utils;

$sdktest::nightly_remote_name = 'eos-sdk';

sub add_nightly_sdk_repo {
    my $self = shift;
    my $repo = 'http://endlessm.github.io/eos-knowledge-lib/eos-sdk-nightly.flatpakrepo';
    my $collection_id = 'com.endlessm.Dev.Sdk';

    $self->disable_polkit_policy('org.freedesktop.Flatpak.configure-remote',
                                 '90-flatpak-configure-remote.rules');
    $self->user_console();

    # Do we actually need to add the remote? Nightly OS images have it enabled
    # already. Note the inverted logic here because script_run() returns the
    # exit status of its script.
    if (script_run('flatpak remotes -d | grep -q ' . $collection_id) != 0) {
        $sdktest::nightly_remote_name = 'eos-sdk-nightly';
        assert_script_run('flatpak remote-add --from eos-sdk-nightly ' . $repo);
    }

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

    # FIXME: Work around gnome-software automatically installing Chrome on first
    # boot, and sometimes raising a polkit authentication dialogue about it, iff
    # we are in a VT when the installation process starts (which would mark the
    # main graphical session as inactive, and hence the normal polkit rules
    # which allow software installation without authorisation would not apply).
    assert_script_run('pkill gnome-software', 1800);

    if (!$run_with_nightly_sdk) {
        $self->exit_user_console();
    }

    if ($run_with_nightly_sdk) {
        assert_script_run('flatpak install -y ' . $sdktest::nightly_remote_name . ' ' . $runtime_id, 1800);
        $self->exit_user_console();

        check_desktop_clean();
        type_very_safely("gnome-terminal\n");
        assert_screen('desktop_terminal', 5);
        type_string("flatpak run --runtime=$runtime_id $app_id &>/dev/null &\n");
    } else {
        check_desktop_clean();
        type_very_safely("gnome-terminal\n");
        assert_screen('desktop_terminal', 5);
        type_string("flatpak run $app_id &>/dev/null &\n");
    }
    # We want to be sure that after switching back to the desktop, the cursor
    # is not over a part of the screen that changes its behavior when the cursor
    # is over.
    mouse_hide();
}

1;
