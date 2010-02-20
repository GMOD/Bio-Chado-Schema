use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::Warn;

use_ok(  'Bio::Chado::Schema'  )
    or BAIL_OUT('could not include the module being tested');

# test merge_schemas
my $new_schema = Bio::Chado::Schema->merge_schemas( 'Test::Schema::One', 'My::Schema' );

can_ok( $new_schema, 'resultset' );
can_ok( $new_schema, 'storage' );
is_deeply( [ sort $new_schema->sources ],
           [ 'TableOne', 'ToBeComposed', ],
           'schemas merged OK',
         );

# test moniker collision check
My::Schema->load_classes('TableOne');
throws_ok {
    Bio::Chado::Schema->merge_schemas( 'Test::Schema::One','My::Schema' );
} qr/both My::Schema and Test::Schema::One have moniker TableOne/,
    'correct throw for moniker collisions';

done_testing;

# to work around a bug in perl, table name collision warning test is
# in dbicfactory_2.t in this dir.  test apparently hits perl bug 52610,
# http://rt.perl.org/rt3/Public/Bug/Display.html?id=52610

# schemas and classes for testing
BEGIN {
    package My::Schema::ToBeComposed;
    use strict;
    use warnings;
    use base 'DBIx::Class';

    __PACKAGE__->load_components(qw/Core/);
    __PACKAGE__->table('tobecomposed');
    __PACKAGE__->add_columns(qw/id somethingelse/);
    __PACKAGE__->set_primary_key('id');

    package My::Schema;
    use base 'DBIx::Class::Schema';

    __PACKAGE__->load_classes('ToBeComposed');

    package Test::Schema::One::TableOne;
    use strict;
    use warnings;
    use base 'DBIx::Class';

    __PACKAGE__->load_components(qw/Core/);
    __PACKAGE__->table('tableone');
    __PACKAGE__->add_columns(qw/id somethingelse/);
    __PACKAGE__->set_primary_key('id');

    package Test::Schema::One;
    use base 'DBIx::Class::Schema';

    __PACKAGE__->load_classes('TableOne');


    # this package is not loaded until later, to test moniker and table name collisions
    package My::Schema::TableOne;

    use strict;
    use warnings;
    use base 'DBIx::Class';

    __PACKAGE__->load_components(qw/Core/);
    __PACKAGE__->table('non_colliding_table_name');
    __PACKAGE__->add_columns(qw/id somethingelse/);
    __PACKAGE__->set_primary_key('id');

    package My::Schema::CollidingTable;
    use strict;
    use warnings;
    use base 'DBIx::Class';

    __PACKAGE__->load_components(qw/Core/);
    __PACKAGE__->table('tableone');
    __PACKAGE__->add_columns(qw/id somethingelse/);
    __PACKAGE__->set_primary_key('id');

}


