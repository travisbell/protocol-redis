# Releases

## Unreleased

  - Close connections when reading a response fails before it is fully consumed.

## v0.13.0

    - Handle `nil` return value in `hgetall` method.

## v0.12.0

  - Introduce `Pubsub#spublish` method for shard channels.

## v0.11.0

  - Introduce cluster methods, including `Strings`, `Streams`, `Scripting` and `Pubsub`.

## v0.10.0

  - Add agent context.
  - 100% documentation and test coverage + minor bug fixes.

## v0.9.0

  - Add support for `client info` command.

## v0.8.1

  - Fix HSCAN method implementation.

## v0.8.0

  - Add missing `hscan` method.
  - Add `mapped_hmget` and `mapped_hmset` methods to match `redis-rb` gem interface.
  - Add cluster methods to client.
  - Make hashes methods compatible with redis-rb.

## v0.7.0

  - Add scripting methods to client and fix script interface.
  - Include sets and streams in the protocol methods.
  - Add support for essential `exists?` method.
  - Prefer bake-gem for release management.

## v0.6.1

  - Add support for multi-argument auth.

## v0.6.0

  - Add relevant pubsub method group.

## v0.5.1

  - Add tests for info command, streams, and string methods.
  - Use correct CRLF constant in server methods.
  - Modernize gem configuration.

## v0.5.0

  - Add incomplete implementations of scripting, sets and streams.
  - Merge existing sorted set implementations.
  - Add `zrangebyscore` method.
  - Improve argument management.
  - Modernize testing infrastructure.

## v0.4.2

  - Prefer implicit returns and improve return value for `setnx`.

## v0.4.1

  - Prefer implicit returns and direct calls (avoid indirection in set methods).

## v0.4.0

  - Add sorted set methods (ZADD, ZREM, ZRANGE, etc.).
  - Use keyword arguments for better API design.
  - Normalize implementations and keyword arguments.
  - Add call(\*arguments) benchmark.
  - Prefer frozen string literals.

## v0.3.1

  - Fix LREM command implementation.
  - Add Ruby 2.7 to CI testing.
  - Drop support for older Ruby versions.

## v0.3.0

  - Add connection, counting and geospatial modules.
  - Add support for generating modules automatically.
  - Fix `Generic#migrate` method.
  - Match module name with Redis group name.
  - Add missing implementations.
  - Count number of requests for performance monitoring.

## v0.2.0

  - Move methods from async-redis.
  - Raise `EOFError` when object could not be read.
  - Fix broken require statements.
  - Avoid allocating extra Array for performance.
  - Add link to RESP3 spec and sample usage.
  - Add string method specifications.

## v0.1.0

  - Initial release.
