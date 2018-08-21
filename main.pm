use strict;
use testapi;
use autotest;
use needle;

# distribution-specific implementations of expected methods
my $distri = testapi::get_var('CASEDIR') . '/lib/endlessdistribution.pm';
require $distri;
testapi::set_distribution(endlessdistribution->new());

# The test suite runs through several phases:
#  - Boot
#  - Install/First boot
#  - Postinstall
#  -
# These phases are very suspiciously similar to what Fedora does
# (https://pagure.io/fedora-qa/os-autoinst-distri-fedora/).
# The preinstall and install phases can be skipped by tests which set HDD_1 to
# a qcow2 image saved from an earlier phase. Typically these tests will also set
#  - POSTINSTALL = (test to run in postinstall phase)
#  - START_AFTER_TEST = install_default_upload
#  - BOOTFROM = c
#  - HDD_1 = disk_%FLAVOR%_%MACHINE%.qcow2
# For details of START_AFTER_TEST, see
# https://github.com/os-autoinst/openQA/blob/master/docs/WritingTests.asciidoc#user-content-job-dependencies.
# For details of BOOTFROM and HDD_1, see
# https://github.com/os-autoinst/os-autoinst/blob/master/doc/backend_vars.asciidoc.

# Boot phase
# ---

if (!get_var("START_AFTER_TEST") && !get_var("BOOTFROM")) {
    # boot phase is loaded automatically every time
    autotest::loadtest "tests/_boot.pm";
}

# Install/First boot phase
# ---

if (!get_var("START_AFTER_TEST") && !get_var("BOOTFROM")) {
    if (!get_var('LIVE')) {
        autotest::loadtest "tests/_fbe_install.pm";
    }

    # After installing, we need to run through the initial setup. We also need
    # to run through it when booting a live image.
    autotest::loadtest "tests/_fbe.pm";
}

# Postinstall phase
# ---

if (get_var("POSTINSTALL")) {
    my @pis = split(/ /, get_var("POSTINSTALL"));
    foreach my $pi (@pis) {
        autotest::loadtest "tests/${pi}.pm";
    }
}

# We need to shut down before uploading disk images, otherwise OpenQA complains
# and fails the test run.
if (get_var("STORE_HDD_1") || get_var("PUBLISH_HDD_1")) {
    autotest::loadtest "tests/_console_shutdown.pm";
}

1;
