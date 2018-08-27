use base 'installedtest';
use strict;
use testapi;

sub run {
    my $self = shift;
    $self->root_console(tty=>4);

    # FIXME: this skips upload_logs, which fails due to curl not being on the images
    set_var('OFFLINE_SUT', 1);

    assert_script_run('top -i -n20 -b > /var/tmp/top.log', 120);
    upload_logs('/var/tmp/top.log');
    unless (get_var('CANNED')) {
        assert_script_run('apt list --installed | sort -u > /var/tmp/packages.log');
        upload_logs('/var/tmp/packages.log');
    }
    assert_script_run('free > /var/tmp/free.log');
    upload_logs('/var/tmp/free.log');
    assert_script_run('df > /var/tmp/df.log');
    upload_logs('/var/tmp/df.log');
    assert_script_run('systemctl -t service --no-pager --no-legend | grep -o ".*\.service" > /var/tmp/services.log');
    upload_logs('/var/tmp/services.log');
}

sub test_flags {
    return { 'ignore_failure' => 1 };
}

1;
