# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2025, by Samuel Williams.

require "protocol/redis/connection"
require "protocol/redis/connection_context"

describe Protocol::Redis::Connection do
	include_context Protocol::Redis::ConnectionContext
	
	with "#write_object" do
		it "can write strings" do
			client.write_object("Hello World!")
			
			expect(server.read_object).to be == "Hello World!"
		end
		
		it "can write arrays" do
			client.write_object(["SET", "key", "value"])
			
			expect(server.read_object).to be == ["SET", "key", "value"]
		end
		
		it "can write integers" do
			client.write_object(42)
			
			expect(server.read_object).to be == 42
		end
		
		it "can write nil" do
			client.write_object(nil)
			
			expect(server.read_object).to be == nil
		end
		
		it "can write objects with to_redis method" do
			custom_object = Object.new
			def custom_object.to_redis
				"custom_value"
			end
			
			client.write_object(custom_object)
			
			expect(server.read_object).to be == "custom_value"
		end
	end
	
	with "#write_request" do
		it "can write request arguments" do
			client.write_request(["SET", "key", "value"])
			
			expect(server.read_object).to be == ["SET", "key", "value"]
		end
	end
	
	with "#read_object" do
		it "can read arrays" do
			server.write_object(["GET", "key"])
			
			expect(client.read_object).to be == ["GET", "key"]
		end
		
		it "can read integers" do
			server.write_object(123)
			
			expect(client.read_object).to be == 123
		end
		
		it "can read nil values" do
			server.write_object(nil)
			
			expect(client.read_object).to be == nil
		end
		
		it "can read null arrays" do
			server.stream.write("*-1\r\n")
			server.stream.flush
			
			expect(client.read_object).to be == nil
		end
		
		it "can read status replies" do
			server.stream.write("+OK\r\n")
			server.stream.flush
			
			expect(client.read_object).to be == "OK"
			expect(client.closed?).to be == false
		end
		
		it "can handle server errors" do
			server.stream.write("-ERR unknown command\r\n")
			server.stream.flush
			
			expect do
				client.read_object
			end.to raise_exception(Protocol::Redis::ServerError)
		end
		
		it "can continue reading after a server error" do
			server.stream.write("-ERR unknown command\r\n+OK\r\n")
			server.stream.flush
			
			expect do
				client.read_object
			end.to raise_exception(Protocol::Redis::ServerError)
			
			expect(client.read_object).to be == "OK"
		end
		
		it "closes the connection when a server error interrupts an array" do
			server.stream.write("*2\r\n-ERR unknown command\r\n+OK\r\n")
			server.stream.flush
			
			expect do
				client.read_object
			end.to raise_exception(Protocol::Redis::ServerError)
			
			expect(client.closed?).to be == true
		end
		
		it "can handle unknown tokens" do
			server.stream.write("<unknown\r\n")
			server.stream.flush
			
			expect do
				client.read_object
			end.to raise_exception(Protocol::Redis::UnknownTokenError)
		end
		
		it "closes the connection on EOF" do
			server.close
			
			expect do
				client.read_object
			end.to raise_exception(EOFError)
			
			expect(client.closed?).to be == true
		end
		
		it "closes the connection on unknown token error" do
			server.stream.write("<unknown\r\n")
			server.stream.flush
			
			expect do
				client.read_object
			end.to raise_exception(Protocol::Redis::UnknownTokenError)
			
			expect(client.closed?).to be == true
		end
	end
	
	with "#write_lines" do
		it "can write empty arguments" do
			expect(client.stream).to receive(:write).with("\r\n")
			
			client.send(:write_lines)
		end
	end
	
	with "#close" do
		it "can close the connection" do
			client.close
			
			expect(client.closed?).to be == true
		end
	end
	
	with "#flush" do
		it "can flush the connection" do
			expect(client.stream).to receive(:flush)
			
			client.flush
		end
	end
end
