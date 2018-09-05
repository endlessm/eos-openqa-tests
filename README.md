Endless OS OpenQA tests
===

This repository contains a set of tests for Endless OS which get run on our
OpenQA instance (https://openqa.dev.endlessm.com/) for every OS image build
produced by our image builder.

Documentation
---

The bulk of the documentation for these tests is in the wiki, which provides an
overview and a guide to writing new tests:
 * [EOS OpenQA overview](https://phabricator.endlessm.com/w/software/build/openqa/)
 * [Writing new tests](https://phabricator.endlessm.com/w/software/build/openqa/writing-tests/)

OpenQA itself provides various pieces of documentation:
 * [Documentation as a single page](http://open.qa/docs/)
 * [Documentation overview](http://open.qa/documentation/)
 * [Test API](http://open.qa/api/testapi/)

Variables
---

Each test scheduled by OpenQA is essentially a dictionary of variables which
control how the test is run. Many of these variables are well-known to OpenQA,
and control which OS image and worker are used to run the test, and how the VM
is set up.

Some of these variables are documented in the
[OpenQA documentation](http://open.qa/docs/#_test_suites) and
[os-autoinst documentation](https://github.com/os-autoinst/os-autoinst/blob/master/doc/backend_vars.asciidoc).

Other variables are well-known to the test harness, and control which test
modules are loaded from the `tests/` directory. These affect the control flow
in `main.pm`, and are documented below. Common OpenQA/os-autoinst variables have
been included too, for convenience.

| Variable | Values allowed | Default value | Description |
| -------- | -------------- | ------------- | ----------- |
| `BOOTFROM` | String | Undefined | Sets the boot order for QEMU. See documentation for `qemu -boot` for accepted values and their meanings. Understood by os-autoinst. |
| `LIVE` | Boolean | False | The test is running on a live system rather than being installed. Specific to eos-openqa-tests. |
| `OS_UPDATE_TO` | OS version number string | Undefined | EOS should be updated after installation, and the tests should expect that the update results in running the given OS version (as checked against `/etc/os-release`). If this variable is not set, the OS will not be updated. Specific to eos-openqa-tests. |
| `POSTINSTALL` | Space separated list of test names, string | Undefined | The given tests should be run, in order, in the post-install phase of `main.pm`, after logging in to GDM. Each test name should refer to an existing `tests/$(name).pm` module in eos-openqa-tests. Specific to eos-openqa-tests. |
| `PUBLISH_HDD_1` | Filename for HDD image, string | Undefined | Publicly publish a qcow2 image of the VM’s HDD after the test completes successfully, using the given filename for it. Understood by os-autoinst. |
| `START_AFTER_TEST` | Test name, string | Undefined | Schedule this test to be run only once the given test has completed, as an ordering constraint. Understood by OpenQA. |
| `STORE_HDD_1` | Filename for HDD image, string | Undefined | As for `PUBLISH_HDD_1`, but store the image privately, so it can only be used by other tests within this test job. Understood by os-autoinst. |

Update tests
---

One of the key goals of the OpenQA testing is to automatically test OS updates
between different releases of Endless OS. Specifically, we care about the cases:

 * For a new minor release 3.`$old` on an old branch, we want to run all the
   tests on 3.`$old`, and we want to update to and run the update tests on
   3.`$latest`.
 * For a new release 3.`$latest`, we want to run all the tests on 3.`$latest`,
   and we want to update from and run the update tests on 3.`$latest-1`,
   3.`$latest-2`, 3.`$latest-3`, etc.

‘The update tests’ may be all tests, or a critical subset of them.

The `OS_UPDATE_TO` variable controls whether an OS update is performed after
installation. So in those cases above:

 * For a new minor release 3.`$old`, trigger tests on 3.`$old` without
   `OS_UPDATE_TO`; and trigger tests on 3.`$old` with `OS_UPDATE_TO=3.$latest`.
 * For a new release 3.`$latest`, trigger tests on 3.`$latest` without
   `OS_UPDATE_TO`; and trigger tests on each of 3.`$latest-1..n` with
   `OS_UPDATE_TO=3.$latest`.

It’s expected that tests aren’t triggered from before the most recent checkpoint,
since the update code in `_os_update.pm` will not successfully update through
a checkpoint, and checkpoints provide an obvious place to break long update
chains. The idea is that if a system passes the tests after upgrading to version
3.`$checkpoint`, it should pass the tests after upgrading onwards from that
version. This behaviour could, however, be changed in future by expanding
`_os_update.pm` to deal with checkpoints.

Note that these update tests don’t cover testing the situation where the user
installed 3.`$x`, then stepwise update 3.`$x` → 3.`$x+1` → 3.`$x+2` → 3.`$x+3`
→ …. We will always end up testing the largest update step possible. In order to
test stepwise updates we’d need to keep intermediate qcow2 images around from
historic test runs. We do not currently do that.