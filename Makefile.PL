use inc::Module::Install;
include 'Module::AutoInstall';

name 'LWP-UserAgent-ProgressBar';
all_from 'lib/LWP/UserAgent/ProgressBar.pm';
perl_version '5.006';

requires 'LWP::UserAgent';
requires 'Term::ProgressBar';

recommends 'Test::Pod';
recommends 'Test::Pod::Coverage';

test_requires 'Test::Differences';
test_requires 'Test::More' => '0.70';
test_requires 'Test::Compile';

auto_install;
auto_include;
WriteAll;
