# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025-2026, by Samuel Williams.

module Protocol
	module Redis
		module Cluster
			module Methods
				# Provides Redis Streams commands for cluster environments.
				# Stream operations are routed to the appropriate shard based on the stream key.
				module Streams
					# Get information on streams and consumer groups.
					# @parameter arguments [Array] XINFO command arguments (subcommand and stream key).
					# @parameter role [Symbol] The role of node to use (`:master` or `:slave`).
					# @returns [Array] Stream information.
					def xinfo(*arguments, role: :master)
						# Extract stream key (usually the second argument after subcommand):
						stream_key = arguments[1] if arguments.length > 1
						
						if stream_key
							slot = slot_for(stream_key)
							client = client_for(slot, role)
						else
							# Fallback for commands without a specific key:
							client = any_client(role)
						end
						
						return client.call("XINFO", *arguments)
					end
					
					# Append a new entry to a stream.
					# @parameter key [String] The stream key.
					# @parameter arguments [Array] Additional XADD arguments (ID and field-value pairs).
					# @parameter role [Symbol] The role of node to use (`:master` or `:slave`).
					# @returns [String] The ID of the added entry.
					def xadd(key, *arguments, role: :master)
						slot = slot_for(key)
						client = client_for(slot, role)
						
						return client.call("XADD", key, *arguments)
					end
					
					# Trim the stream to a certain size.
					# @parameter key [String] The stream key.
					# @parameter arguments [Array] Trim strategy and parameters.
					# @parameter role [Symbol] The role of node to use (`:master` or `:slave`).
					# @returns [Integer] Number of entries removed.
					def xtrim(key, *arguments, role: :master)
						slot = slot_for(key)
						client = client_for(slot, role)
						
						return client.call("XTRIM", key, *arguments)
					end
					
					# Remove specified entries from the stream.
					# @parameter key [String] The stream key.
					# @parameter arguments [Array] Entry IDs to remove.
					# @parameter role [Symbol] The role of node to use (`:master` or `:slave`).
					# @returns [Integer] Number of entries actually deleted.
					def xdel(key, *arguments, role: :master)
						slot = slot_for(key)
						client = client_for(slot, role)
						
						return client.call("XDEL", key, *arguments)
					end
					
					# Return a range of elements in a stream.
					# @parameter key [String] The stream key.
					# @parameter arguments [Array] Range parameters (start, end, optional COUNT).
					# @parameter role [Symbol] The role of node to use (`:master` or `:slave`).
					# @returns [Array] Stream entries in the specified range.
					def xrange(key, *arguments, role: :master)
						slot = slot_for(key)
						client = client_for(slot, role)
						
						return client.call("XRANGE", key, *arguments)
					end
					
					# Return a range of elements in a stream in reverse order.
					# @parameter key [String] The stream key.
					# @parameter arguments [Array] Range parameters (end, start, optional COUNT).
					# @parameter role [Symbol] The role of node to use (`:master` or `:slave`).
					# @returns [Array] Stream entries in reverse order.
					def xrevrange(key, *arguments, role: :master)
						slot = slot_for(key)
						client = client_for(slot, role)
						
						return client.call("XREVRANGE", key, *arguments)
					end
					
					# Return the number of entries in a stream.
					# @parameter key [String] The stream key.
					# @parameter role [Symbol] The role of node to use (`:master` or `:slave`).
					# @returns [Integer] Number of entries in the stream.
					def xlen(key, role: :master)
						slot = slot_for(key)
						client = client_for(slot, role)
						
						return client.call("XLEN", key)
					end
					
					# Read new entries from multiple streams.
					# Note: In cluster mode, all streams in a single XREAD must be on the same shard.
					# @parameter arguments [Array] XREAD arguments including STREAMS keyword and stream keys/IDs.
					# @parameter role [Symbol] The role of node to use (`:master` or `:slave`).
					# @returns [Array] New entries from the specified streams.
					def xread(*arguments, role: :master)
						# Extract first stream key to determine shard:
						streams_index = arguments.index("STREAMS")
						
						if streams_index && streams_index + 1 < arguments.length
							first_stream_key = arguments[streams_index + 1]
							slot = slot_for(first_stream_key)
							client = client_for(slot, role)
						else
							# Fallback if STREAMS keyword not found:
							client = any_client(role)
						end
						
						return client.call("XREAD", *arguments)
					end
					
					# Create, destroy, and manage consumer groups.
					# @parameter arguments [Array] XGROUP command arguments.
					# @parameter role [Symbol] The role of node to use (`:master` or `:slave`).
					# @returns [String | Integer] Command result.
					def xgroup(*arguments, role: :master)
						# Extract stream key (usually third argument for CREATE, second for others):
						stream_key = case arguments[0]&.upcase
						when "CREATE", "SETID"
							arguments[1] # CREATE stream group id, SETID stream group id
						when "DESTROY", "DELCONSUMER"
							arguments[1] # DESTROY stream group, DELCONSUMER stream group consumer
						else
							arguments[1] if arguments.length > 1
						end
						
						if stream_key
							slot = slot_for(stream_key)
							client = client_for(slot, role)
						else
							client = any_client(role)
						end
						
						return client.call("XGROUP", *arguments)
					end
					
					# Read new entries from streams using a consumer group.
					# @parameter arguments [Array] XREADGROUP arguments.
					# @parameter role [Symbol] The role of node to use (`:master` or `:slave`).
					# @returns [Array] Entries for the consumer group.
					def xreadgroup(*arguments, role: :master)
						# Extract first stream key to determine shard:
						streams_index = arguments.index("STREAMS")
						
						if streams_index && streams_index + 1 < arguments.length
							first_stream_key = arguments[streams_index + 1]
							slot = slot_for(first_stream_key)
							client = client_for(slot, role)
						else
							client = any_client(role)
						end
						
						return client.call("XREADGROUP", *arguments)
					end
					
					# Acknowledge processed messages in a consumer group.
					# @parameter key [String] The stream key.
					# @parameter arguments [Array] Group name and message IDs.
					# @parameter role [Symbol] The role of node to use (`:master` or `:slave`).
					# @returns [Integer] Number of messages acknowledged.
					def xack(key, *arguments, role: :master)
						slot = slot_for(key)
						client = client_for(slot, role)
						
						return client.call("XACK", key, *arguments)
					end
					
					# Change ownership of messages in a consumer group.
					# @parameter key [String] The stream key.
					# @parameter arguments [Array] Group, consumer, min-idle-time, and message IDs.
					# @parameter role [Symbol] The role of node to use (`:master` or `:slave`).
					# @returns [Array] Claimed messages.
					def xclaim(key, *arguments, role: :master)
						slot = slot_for(key)
						client = client_for(slot, role)
						
						return client.call("XCLAIM", key, *arguments)
					end
					
					# Get information about pending messages in a consumer group.
					# @parameter key [String] The stream key.
					# @parameter arguments [Array] Group name and optional consumer/range parameters.
					# @parameter role [Symbol] The role of node to use (`:master` or `:slave`).
					# @returns [Array] Pending message information.
					def xpending(key, *arguments, role: :master)
						slot = slot_for(key)
						client = client_for(slot, role)
						
						return client.call("XPENDING", key, *arguments)
					end
				end
			end
		end
	end
end
