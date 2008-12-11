use inc::Module::Install;
include 'Module::AutoInstall';

name 'LWP-UserAgent-ProgressBar';
all_from 'lib/LWP/UserAgent/ProgressBar.pm';
perl_version '5.006';

requires 'LWP::UserAgent';
requires 'Term::ProgressBar';

test_requires 'Test::Differences';
test_requires 'Test::More' => '0.70';
extra_tests;

auto_install;
auto_include;
WriteAll;
