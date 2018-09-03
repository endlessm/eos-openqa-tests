use base 'installedtest';
use strict;
use testapi;

sub run {
    my $self = shift;
    $self->root_console(tty=>4);
    $self->ensure_curl_available();

    assert_script_run('top -i -n20 -b > /var/tmp/top.log', 120);
    upload_logs('/var/tmp/top.log');

    assert_script_run('apt list --installed | sort -u > /var/tmp/packages.log');
    upload_logs('/var/tmp/packages.log');

    assert_script_run('free > /var/tmp/free.log');
    upload_logs('/var/tmp/free.log');

    assert_script_run('df > /var/tmp/df.log');
    upload_logs('/var/tmp/df.log');

    assert_script_run('systemctl -t service --no-pager --no-legend | grep -o ".*\.service" > /var/tmp/services.log');
    upload_logs('/var/tmp/services.log');

    # upload any core dump files caught by coredumpctl
    unless (script_run('test -n "$(ls -A /var/lib/systemd/coredump)" && tar czvf /var/tmp/coredump.tar.gz /var/lib/systemd/coredump')) {
        upload_logs('/var/tmp/coredump.tar.gz');
    }

    # Upload /var/log
    # lastlog can mess up tar sometimes and it's not much use
    assert_script_run("tar czvf /var/tmp/var_log.tar.gz --exclude='lastlog' /var/log");
    upload_logs('/var/tmp/var_log.tar.gz');

    $self->exit_root_console();
}

sub test_flags {
    return { 'ignore_failure' => 1 };
}

1;
