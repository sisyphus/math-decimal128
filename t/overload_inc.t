# test '++' and '--' overloading.
use strict;
use warnings;
use Math::Decimal128 qw(:all);

use Test::More;

my $obj0 = Math::Decimal128->new('32.1');

$obj0++;
cmp_ok($obj0, '==', '33.1', 'postfix ++ ok');

$obj0--;
cmp_ok($obj0, '==', '32.1', 'postfix -- ok');

my $obj1 = $obj0++;
cmp_ok($obj1 - $obj0, '==', '-1', "$obj0 1 greater than $obj1");

my $obj2 = ++$obj0;
cmp_ok($obj2, '==', $obj0, "$obj2 == $obj0");

cmp_ok($obj2 - $obj1, '==', '2', "$obj2 is 2 greater than $obj1");

done_testing();
