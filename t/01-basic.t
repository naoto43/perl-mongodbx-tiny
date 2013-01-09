#!/usr/bin/env perl

use strict;
use Data::Dumper;
use Test::More tests => 1;

$ENV{MONGODBX_TINY_DEBUG} = 1;

package main;

ok(my_test());

use FindBin;
use lib $FindBin::Bin . "/../t/lib";
use MyData;

sub my_test {
    my $tiny = MyData->new;
    use Digest::SHA;
    $tiny->remove('foo',{ code => 123});
    $tiny->remove('foo',{ code => "foo_123"});

    my $foo  = $tiny->insert(foo => { code => Digest::SHA::sha1_hex(time . $$ . rand() . {}), name => "foo_123"});

    $tiny->set_indexes('foo');

    $foo->is_my_data_document;
    $foo->name('foo_321');	# not changed on database
    $foo->update;		# changed

    $foo->update({ name => "foo_0" });

    my $bar  = $tiny->insert(bar => { foo_id => $foo->id, code => 1, name => "foo_bar" });

    my $bar2 = $foo->bar;

    $bar2->remove;

    my $validator = $tiny->validate('foo',{ code =>  Digest::SHA::sha1_hex(time . $$ . rand() . {}), name => "foo_123"},{ state => 'insert' });
    my $foo1      = $tiny->insert('foo',$validator->document,{ state => 'insert', no_validate => 1 });
    my @errors         = $validator->errors; # [{ field => 'field1', code => 'errorcode', message => 'message1' },,,]
    my @fields          = $validator->errors('field');
    my @error_code    = $validator->errors('code');
    my @error_message = $validator->errors('message');

    $tiny->process('foo','some',$validator); # just call Data::Foo::process_some
    my @oid_field = $tiny->document_class('bar')->field->list('OID'); # call class method directly
    my $foo2 = $tiny->single(foo => $foo->id); # single(foo => $foo);
    my $foo3 = $tiny->single(foo => { code =>  Digest::SHA::sha1_hex(time . $$ . rand() . {}) });
    my $cache;
    {
	package test::cache;
	no strict 'refs';
	*{"test::cache::set"} = sub {
	    my $self = shift;
	    my ($key,$val) = @_;
	    $self->{$key} = $val;
	    return $val;
	};
	*{"test::cache::get"} = sub {
	    my $self = shift;
	    my ($key) = @_;
	    return $self->{$key};
	};
	*{"test::cache::new"} = sub {
	    bless {}, shift;
	};

    }
    $cache = test::cache->new;

    my $foo_cache1 = $tiny->single_by_cache(foo => $foo->id->value,{ cache => $cache});
    my $foo_cache2 = $tiny->single_by_cache(foo => $foo->id->value,{ cache => $cache});

    my @list = $tiny->search(foo => { name => 'foo_123'});

    # like MongoDB::Cursor
    my $cursor = $tiny->search(foo => { name => 'foo_123'});
    while (my $rec = $cursor->next) {
	# warn $rec->id;
    }

    $tiny->count(foo => { code => 123 });

    # get MongoDB connection object
    $tiny->connection;

    # get MongoDB database object
    $tiny->database;

    # get MongoDB collection object
    $tiny->collection('foo');

    # get Tiny object
    my $tiny2 = $foo->tiny;

    # manage gridfs
    my $gridfs = $tiny->gridfs;
    $gridfs->put('/etc/passwd', {"filename" => '/my/foo.txt' });
    my $foo_txt = $gridfs->get({ filename => '/my/foo.txt' })->slurp;

    $gridfs->put('/etc/passwd','/my/bar.txt');
    my $bar_txt = $gridfs->get('/my/bar.txt')->slurp;

    return 1;
}



