use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # Do the upgrade.
    # FIXME: Currently we don’t fail if this fails, because the state management
    # of `eos-updater-ctl update` is a bit flaky. We’ll catch any update
    # mismatches with the version check below. It would be good to catch them
    # sooner though, once eos-updater-ctl is a little less rubbish.
    $self->root_console();
    script_run('eos-updater-ctl update', 180);

    # Upgrade complete; reboot. Sleep for 2s to avoid matching the shutdown
    # Plymouth screen.
    type_string("reboot\n");
    sleep(2);
    assert_screen('plymouth', 60);
    send_key('esc');  # Press Esc to show the boot progress for debugging
    assert_screen('gdm_user_list', 600);

    # Check we’re now in the right version.
    $self->root_console();
    my $expected_booted_version = get_var('OS_UPDATE_TO');
    my $booted_version = script_output('grep VERSION_ID /etc/os-release');
    $self->exit_root_console();

    if ($booted_version ne "VERSION_ID=\"$expected_booted_version\"") {
        die("Unexpected version $booted_version instead of $expected_booted_version");
        return;
    }
}

sub test_flags {
    # Treat success as a milestone worthy of updating ‘last good’ status
    return { fatal => 1, milestone => 1 };
}

1;
