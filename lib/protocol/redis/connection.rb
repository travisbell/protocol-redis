# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2026, by Samuel Williams.

require_relative "error"

module Protocol
	module Redis
		# Represents a Redis protocol connection handling low-level communication.
		class Connection
			CRLF = "\r\n".freeze
			
			# Initialize a new connection with the provided stream.
			# @parameter stream [IO] The underlying stream for communication.
			def initialize(stream)
				@stream = stream
				
				# Number of requests sent:
				@count = 0
			end
			
			attr :stream
			
			# @attr [Integer] Number of requests sent.
			attr :count
			
			# Close the underlying stream connection.
			def close
				@stream.close
			end
			
			class << self
				# Create a new client connection instance.
				alias client new
			end
			
			# Flush any buffered data to the stream.
			def flush
				@stream.flush
			end
			
			# Check if the connection is closed.
			# @returns [Boolean] True if the connection is closed.
			def closed?
				@stream.closed?
			end
			
			# The redis server doesn't want actual objects (e.g. integers) but only bulk strings. So, we inline it for performance.
			def write_request(arguments)
				write_lines("*#{arguments.size}")
				
				@count += 1
				
				arguments.each do |argument|
					string = argument.to_s
					
					write_lines("$#{string.bytesize}", string)
				end
			end
			
			# Write a Redis object to the stream.
			# @parameter object [Object] The object to write (String, Array, Integer, or object with to_redis method).
			def write_object(object)
				case object
				when String
					write_lines("$#{object.bytesize}", object)
				when Array
					write_array(object)
				when Integer
					write_lines(":#{object}")
				when nil
					write_lines("$-1")
				else
					write_object(object.to_redis)
				end
			end
			
			# Write a Redis array to the stream.
			# @parameter array [Array] The array to write.
			def write_array(array)
				write_lines("*#{array.size}")
				
				array.each do |element|
					write_object(element)
				end
			end
			
			# Read data of specified length from the stream.
			# @parameter length [Integer] The number of bytes to read.
			# @returns [String] The data read from the stream.
			def read_data(length)
				buffer = @stream.read(length) or @stream.eof!
				
				# Eat trailing whitespace because length does not include the CRLF:
				@stream.read(2) or @stream.eof!
				
				return buffer
			end
			
			# Read and parse a Redis object from the stream.
			# @returns [Object] The parsed Redis object (String, Array, Integer, or nil).
			# @raises [ServerError] If the server returns an error response.
			# @raises [EOFError] If the stream reaches end of file.
			def read_object
				# Whether the current response was fully consumed:
				complete = false
				object = nil
				
				# The line that we are processing:
				line = read_line or raise EOFError
				token = line.slice!(0, 1)
				
				case token
				when "$"
					length = line.to_i
					
					if length == -1
						# No data.
					else
						object = read_data(length)
					end
					
					complete = true
				when "*"
					count = line.to_i
					
					if count == -1
						# Null array (https://redis.io/topics/protocol#resp-arrays).
					else
						object = Array.new(count){read_object}
					end
					
					complete = true
				when ":"
					object = line.to_i
					complete = true
				when "-"
					complete = true
					raise ServerError.new(line)
				when "+"
					object = line
					complete = true
				else
					@stream.flush
					
					raise UnknownTokenError, token.inspect
				end
				
				return object
			ensure
				close unless complete
			end
			
			alias read_response read_object
			
			private
			
			# In the case of Redis, we do not want to perform a flush in every line,
			# because each Redis command contains several lines. Flushing once per
			# command is more efficient because it avoids unnecessary writes to the
			# socket.
			def write_lines(*arguments)
				if arguments.empty?
					@stream.write(CRLF)
				else
					arguments.each do |arg|
						@stream.write(arg)
						@stream.write(CRLF)
					end
				end
			end
			
			def read_line
				@stream.gets(CRLF, chomp: true)
			end
		end
	end
end
