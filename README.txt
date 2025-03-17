=== NetBeans MSI Installer Generation Example ===

The scripts in this repo show how an MSI installer can be generated for the
NetBeans IDE.

To generate an installer, set the environment variables described in comments at
the top of WindowsInstaller/buildmsi_ci.bat , and then run the latter script.

For testing, you can edit the environment variables in buildmsi_manual.bat and
run that script instead. The buildmsi_manual.bat script will make an installer
with only a few small files in it, so that build, installation, uninstallation,
and upgrading can be tested quickly.

The buildmsi_manual.bat and buildmsi_ci.bat scripts have been tested, in their
NetBeans adaptations as they exist in this repo, with version 3.11.2 of the
WiX toolset. ( https://github.com/wixtoolset/wix3/releases/tag/wix3112rtm )

Also included is the file .github/workflows/build-windows-installer.yml, which
shows how to call the MSI generation script from a GitHub Actions job, and
then sign the resulting MSI file using Azure Trusted Signing. The
build-windows-installer.yml file was adapted from another project, but has not
been tested afterwards (it assumes access to certain project-specific AWS
resources). Note that the job runs entirely on a windows instance. The original
version of this script takes about 2.5 minutes to run.

With the build-windows-installer action, for a new release, you would edit
release_variables.env and change NETBEANS_VERSION to the new version number,
and replace MSI_PRODUCT_ID with a freshly generated random UUID.

Some basic NetBeans logo graphics have been included in the banner.bmp and
dialog.bmp files. These are used for branding in the MSI installer wizard
dialog. Note that HiDPI-resolution branding images are _not_ supported by MSI.

In its current configuration, the generated installer defaults to a per-user
installation, i.e. one that does _not_ require Administrator rights. There are
ways to change this, in NetBeans.wxs, but I arrived at the current approach
after a lot of experimentation, and recommend it.
