use warnings;
use strict;
use Math::Decimal128 qw(:all);

print "1..1\n";


if($Math::Decimal128::VERSION eq '0.01' && Math::Decimal128::_get_xs_version() eq $Math::Decimal128::VERSION) {print "ok 1\n"}
else {print "not ok 1 $Math::Decimal128::VERSION ", Math::Decimal128::_get_xs_version(), "\n"}

