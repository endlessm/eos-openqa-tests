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
#
# These phases are very suspiciously similar to what Fedora does
# (https://pagure.io/fedora-qa/os-autoinst-distri-fedora/).
# The preinstall and install phases can be skipped by tests which set HDD_1 to
# a qcow2 image saved from an earlier phase. Typically these tests will also set
#  - POSTINSTALL = (test to run in postinstall phase)
#  - START_AFTER_TEST = install_default_upload
#  - BOOTFROM = c
#  - HDD_1 = disk_%FLAVOR%_%MACHINE%.qcow2
# The initial installation test (install_default_upload) uses an installation
# disk set as ISO or a raw image set as HDD_1. When booting from a raw image in
# HDD_1, some initial installation will be done, then a qcow2 image will be
# saved containing the installed disk state. This will be used by all dependent
# tests, to skip running the installation again. The use of the qcow2 image is
# forced in the `templates` file by setting `+HDD_1` rather than `HDD_1`.
# Setting the latter in `templates` would mean its value is overridden by the
# `HDD_1` value provided by eos-image-builder.
#
# For details of START_AFTER_TEST, see
# https://github.com/os-autoinst/openQA/blob/master/docs/WritingTests.asciidoc#user-content-job-dependencies.
# For details of BOOTFROM and HDD_1, see
# https://github.com/os-autoinst/os-autoinst/blob/master/doc/backend_vars.asciidoc.

# Boot phase
# ---

# Boot phase is loaded automatically every time
autotest::loadtest "tests/_boot.pm";

# Install/First boot phase
# ---

if (!get_var('START_AFTER_TEST') && !get_var('BOOTFROM') && !get_var('FBE_TEST')) {
    if (!get_var('LIVE') && get_var('EOS_IMAGE_TYPE') ne 'full') {
        autotest::loadtest "tests/_fbe_install.pm";
    }

    # After installing, we need to run through the initial setup. We also need
    # to run through it when booting a live image.
    autotest::loadtest "tests/_fbe.pm";
    autotest::loadtest "tests/_post_fbe.pm";

    # Enable coredump collection; needed for _check_crashes.pm below.
    autotest::loadtest "tests/_enable_coredumps.pm";

    # Add debugging output for polkit prompts, since the text shown in the UI
    # is often unhelpful.
    autotest::loadtest "tests/_enable_polkit_debugging.pm";

    # Disable notification popups because they get in the way of a lot of needles.
    # Similarly, disable the screensaver and Google Chrome installation.
    autotest::loadtest "tests/_disable_desktop_notifications.pm";
    autotest::loadtest "tests/_disable_screensaver.pm";
    autotest::loadtest "tests/_disable_chrome_installation.pm";

    if (get_var('OS_UPDATE_TO')) {
        autotest::loadtest "tests/_os_update.pm";
    }
}

if (get_var('FBE_TEST')) {
    my @fts = split(/ /, get_var('FBE_TEST'));
    foreach my $ft (@fts) {
        autotest::loadtest "tests/${ft}.pm";
    }
}

# Postinstall phase
# ---

# Log in, but not if we’ve just run though FBE (which leaves the desktop logged
# in).
if (!get_var('LIVE') && !get_var('FBE_TEST') &&
    (get_var("START_AFTER_TEST") || get_var("BOOTFROM"))) {
    autotest::loadtest "tests/_graphical_login.pm";
}

if (get_var("POSTINSTALL")) {
    my @pis = split(/ /, get_var("POSTINSTALL"));
    foreach my $pi (@pis) {
        autotest::loadtest "tests/${pi}.pm";
    }
}

# Always check for and collect data about systemic failures, apart from when
# doing FBE tests, because we’re not in a proper environment then.
if (!get_var('FBE_TEST')) {
    autotest::loadtest "tests/_check_crashes.pm";
    autotest::loadtest "tests/_collect_data.pm";
}

# We need to shut down before uploading disk images, otherwise OpenQA complains
# and fails the test run.
if (get_var("STORE_HDD_1") || get_var("PUBLISH_HDD_1")) {
    autotest::loadtest "tests/_console_shutdown.pm";
}

1;
