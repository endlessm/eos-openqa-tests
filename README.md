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
| `POSTINSTALL` | Space separated list of test names, string | Undefined | The given tests should be run, in order, in the post-install phase of `main.pm`, after logging in to GDM. Each test name should refer to an existing `tests/$(name).pm` module in eos-openqa-tests. Specific to eos-openqa-tests. |
| `PUBLISH_HDD_1` | Filename for HDD image, string | Undefined | Publicly publish a qcow2 image of the VM’s HDD after the test completes successfully, using the given filename for it. Understood by os-autoinst. |
| `START_AFTER_TEST` | Test name, string | Undefined | Schedule this test to be run only once the given test has completed, as an ordering constraint. Understood by OpenQA. |
| `STORE_HDD_1` | Filename for HDD image, string | Undefined | As for `PUBLISH_HDD_1`, but store the image privately, so it can only be used by other tests within this test job. Understood by os-autoinst. |