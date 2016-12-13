use strict;
use warnings;
use utf8;
use Test::More tests => 3;

use FindBin;
use lib "$FindBin::Bin/lib";

use_ok('Catalyst::Test', 'TestApp');

my $response;
ok(($response = request("/test_double_encoding"))->is_success, 'request ok');
ok(3 == ($response->content =~ /àèéìòù/g), "matches 3 times");
diag("Something is wrong about this: " . $response->content);

exit;
