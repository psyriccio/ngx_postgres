# vi:filetype=perl

use lib 'lib';
use Test::Nginx::Socket;

repeat_each(1);

plan tests => repeat_each() * blocks();

$ENV{TEST_NGINX_POSTGRESQL_PORT} ||= 5432;

our $http_config = <<'_EOC_';
    upstream database {
        postgres_server  127.0.0.1:$TEST_NGINX_POSTGRESQL_PORT
                         dbname=ngx_test user=ngx_test password=ngx_test;
    }
_EOC_

worker_connections(128);
no_shuffle();
run_tests();

no_diff();

__DATA__

=== TEST 1: cats - drop table
--- http_config eval: $::http_config
--- config
    location = /init {
        postgres_pass   database;
        postgres_query  "DROP TABLE cats";
        error_page 500  = /ignore;
    }

    location /ignore { echo "ignore"; }
--- request
GET /init
--- error_code: 200
--- timeout: 10



=== TEST 2: cats - create table
--- http_config eval: $::http_config
--- config
    location = /init {
        postgres_pass   database;
        postgres_query  "CREATE TABLE cats (id integer, name text)";
    }
--- request
GET /init
--- error_code: 200
--- timeout: 10



=== TEST 3: cats - insert value
--- http_config eval: $::http_config
--- config
    location = /init {
        postgres_pass   database;
        postgres_query  "INSERT INTO cats (id) VALUES (2)";
    }
--- request
GET /init
--- error_code: 200
--- timeout: 10



=== TEST 4: cats - insert value
--- http_config eval: $::http_config
--- config
    location = /init {
        postgres_pass   database;
        postgres_query  "INSERT INTO cats (id, name) VALUES (3, 'bob')";
    }
--- request
GET /init
--- error_code: 200
--- timeout: 10



=== TEST 5: numbers - drop table
--- http_config eval: $::http_config
--- config
    location = /init {
        postgres_pass   database;
        postgres_query  "DROP TABLE IF EXISTS numbers";
    }
--- request
GET /init
--- error_code: 200
--- timeout: 10



=== TEST 6: numbers - create table
--- http_config eval: $::http_config
--- config
    location = /init {
        postgres_pass   database;
        postgres_query  "CREATE TABLE numbers (number integer)";
    }
--- request
GET /init
--- error_code: 200
--- timeout: 10



=== TEST 7: users - drop table
--- http_config eval: $::http_config
--- config
    location = /init {
        postgres_pass   database;
        postgres_query  "DROP TABLE IF EXISTS users";
    }
--- request
GET /init
--- error_code: 200
--- timeout: 10



=== TEST 8: users - create table
--- http_config eval: $::http_config
--- config
    location = /init {
        postgres_pass   database;
        postgres_query  "CREATE TABLE users (login text, pass text)";
    }
--- request
GET /init
--- error_code: 200
--- timeout: 10



=== TEST 9: users - insert value
--- http_config eval: $::http_config
--- config
    location = /init {
        postgres_pass   database;
        postgres_query  "INSERT INTO users (login, pass) VALUES ('ngx_test', 'ngx_test')";
    }
--- request
GET /init
--- error_code: 200
--- timeout: 10
