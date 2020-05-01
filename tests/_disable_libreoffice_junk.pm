# vi: set shiftwidth=4 tabstop=4 expandtab:
use base 'installedtest';
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;

    # Disable LibreOffice's tip of the day popover
    $self->user_console();
    assert_script_run(q(mkdir -p .var/app/org.libreoffice.LibreOffice/config/libreoffice/4/user));
    assert_script_run(q(echo '<?xml version="1.0" encoding="UTF-8"?> <oor:items xmlns:oor="http://openoffice.org/2001/registry" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <item oor:path="/org.openoffice.Office.Common/Misc"><prop oor:name="ShowTipOfTheDay" oor:op="fuse"><value>false</value></prop></item> </oor:items>' > .var/app/org.libreoffice.LibreOffice/config/libreoffice/4/user/registrymodifications.xcu));
    $self->exit_user_console();

}

sub test_flags {
    return { fatal => 1 };
}

1;
