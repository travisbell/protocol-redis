# Protocol::Redis

Implements the RESP2 and [RESP3](https://github.com/antirez/RESP3) Redis protocols.

[![Development Status](https://github.com/socketry/protocol-redis/workflows/Test/badge.svg)](https://github.com/socketry/protocol-redis/actions?workflow=Test)

## Usage

Please see the [project documentation](https://socketry.github.io/protocol-redis/) for more details.

  - [Getting Started](https://socketry.github.io/protocol-redis/guides/getting-started/index) - This guide explains how to use the `Protocol::Redis` gem to implement the RESP2 and RESP3 Redis protocols for low level client and server implementations.

## Releases

Please see the [project releases](https://socketry.github.io/protocol-redis/releases/index) for all releases.

### v0.13.0

    - Handle `nil` return value in `hgetall` method.

### v0.12.0

  - Introduce `Pubsub#spublish` method for shard channels.

### v0.11.0

  - Introduce cluster methods, including `Strings`, `Streams`, `Scripting` and `Pubsub`.

### v0.10.0

  - Add agent context.
  - 100% documentation and test coverage + minor bug fixes.

### v0.9.0

  - Add support for `client info` command.

### v0.8.1

  - Fix HSCAN method implementation.

### v0.8.0

  - Add missing `hscan` method.
  - Add `mapped_hmget` and `mapped_hmset` methods to match `redis-rb` gem interface.
  - Add cluster methods to client.
  - Make hashes methods compatible with redis-rb.

### v0.7.0

  - Add scripting methods to client and fix script interface.
  - Include sets and streams in the protocol methods.
  - Add support for essential `exists?` method.
  - Prefer bake-gem for release management.

### v0.6.1

  - Add support for multi-argument auth.

### v0.6.0

  - Add relevant pubsub method group.

## Contributing

We welcome contributions to this project.

1.  Fork the repository.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature.'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create a new pull request.

### Running Tests

To run the test suite:

``` bash
$ bundle exec sus
```

### Making Releases

To make a new release:

``` bash
$ bundle exec bake gem:release:patch # or minor or major
```

### Developer Certificate of Origin

In order to protect users of this project, we require all contributors to comply with the [Developer Certificate of Origin](https://developercertificate.org/). This ensures that all contributions are properly licensed and attributed.

### Community Guidelines

This project is best served by a collaborative and respectful environment. Treat each other professionally, respect differing viewpoints, and engage constructively. Harassment, discrimination, or harmful behavior is not tolerated. Communicate clearly, listen actively, and support one another. If any issues arise, please inform the project maintainers.
