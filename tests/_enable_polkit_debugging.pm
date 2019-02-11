# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # Install an additional polkit rule which prints debug information for
    # every authorisation request. This should help debug any problems which are
    # found in tests, especially unexpected authorisation dialogs (where do they
    # come from?).
    $self->root_console();
    assert_script_run('echo "polkit.addRule(function(action, subject) { polkit.log(\"action=\" + action); polkit.log(\"subject=\" + subject); return polkit.Result.NOT_HANDLED; });" > /etc/polkit-1/rules.d/10-debugging.rules', 30);
    $self->exit_root_console();
}

sub test_flags {
    return { fatal => 1 };
}

1;