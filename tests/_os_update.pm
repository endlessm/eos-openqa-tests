# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    $self->root_console();

    # Switch to the appropriate OS update repo stage.
    my $update_to_stage = get_var('OS_UPDATE_TO_STAGE');
    script_run("eos-stage-ostree $update_to_stage", 180);

    # Stop eos-updater to ensure it starts from a clean slate. eos-stage-ostree
    # likely already did this, but let's be sure.
    assert_script_run('systemctl stop eos-updater', timeout => 30);

    # Do the upgrade.
    assert_script_run('eos-updater-ctl update', 180);

    # Record the ostree sysroot status.
    my $ostree_status = script_output('ostree admin status', timeout => 10);
    record_info('OSTree status', $ostree_status);

    # Upgrade complete; reboot. Sleep for 2s to avoid matching the shutdown
    # Plymouth screen.
    assert_script_run("systemctl mask --runtime plymouth-reboot.service", 10);
    type_string("reboot\n");
    wait_serial("reboot");
    if (check_screen('plymouth', 30)) {
        # Press Esc to show the boot progress for debugging
        send_key('esc');
    }
    assert_screen('gdm_user_list', 600);
    reset_consoles();

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
