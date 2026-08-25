# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Troex Nevelin.
# Copyright, 2023-2026, by Samuel Williams.

require "protocol/redis/methods_context"
require "protocol/redis/methods/generic"

describe Protocol::Redis::Methods::Generic do
	include_context Protocol::Redis::MethodsContext, Protocol::Redis::Methods::Generic
	
	let(:key_name) {"mykey"}
	let(:key_name2) {"yourkey"}
	let(:new_key) {"newkey"}
	let(:value) {"value"}
	let(:pattern) {"*"}
	let(:seconds) {60}
	let(:timestamp) {Time.now.to_i + 60}
	
	with "#del" do
		it "can generate correct arguments with single key" do
			expect(object).to receive(:call).with("DEL", key_name).and_return(1)
			
			expect(object.del(key_name)).to be == 1
		end
		
		it "can generate correct arguments with multiple keys" do
			expect(object).to receive(:call).with("DEL", key_name, key_name2).and_return(2)
			
			expect(object.del(key_name, key_name2)).to be == 2
		end
		
		it "returns nil when no keys provided" do
			expect(object.del()).to be_nil
		end
	end
	
	with "#dump" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("DUMP", key_name).and_return(value)
			
			expect(object.dump(key_name)).to be == value
		end
	end
	
	with "#exists" do
		it "can generate correct arguments with single key" do
			expect(object).to receive(:call).with("EXISTS", key_name).and_return(1)
			
			expect(object.exists(key_name)).to be == 1
		end
		
		it "can generate correct arguments with multiple keys" do
			expect(object).to receive(:call).with("EXISTS", key_name, key_name2).and_return(2)
			
			expect(object.exists(key_name, key_name2)).to be == 2
		end
	end
	
	with "#exists?" do
		it "can generate correct arguments" do
			expect(object).to receive(:exists).with(key_name, key_name2).and_return(1)
			
			expect(object.exists?(key_name, key_name2)).to be == true
		end
	end
	
	with "#expire" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("EXPIRE", key_name, seconds).and_return(1)
			
			expect(object.expire(key_name, seconds)).to be == 1
		end
	end
	
	with "#expireat" do
		it "can generate correct arguments with integer timestamp" do
			expect(object).to receive(:call).with("EXPIREAT", key_name, timestamp).and_return(1)
			
			expect(object.expireat(key_name, timestamp)).to be == 1
		end
		
		it "can generate correct arguments with Time object" do
			time = Time.at(timestamp)
			expect(object).to receive(:call).with("EXPIREAT", key_name, timestamp).and_return(1)
			
			expect(object.expireat(key_name, time)).to be == 1
		end
	end
	
	with "#keys" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("KEYS", pattern).and_return([key_name, key_name2])
			
			expect(object.keys(pattern)).to be == [key_name, key_name2]
		end
	end
	
	with "#migrate" do
		let(:host) {"localhost"}
		let(:port) {6380}
		let(:destination) {1}
		let(:timeout) {5000}
		
		it "can generate correct arguments with single key" do
			expect(object).to receive(:call).with("MIGRATE", host, port, key_name, destination, timeout).and_return("OK")
			
			expect(object.migrate(host, port, destination, keys: [key_name], timeout: timeout)).to be == "OK"
		end
		
		it "can generate correct arguments with multiple keys" do
			expect(object).to receive(:call).with("MIGRATE", host, port, "", destination, timeout, "KEYS", key_name, key_name2).and_return("OK")
			
			expect(object.migrate(host, port, destination, keys: [key_name, key_name2], timeout: timeout)).to be == "OK"
		end
		
		it "can generate correct arguments with copy option" do
			expect(object).to receive(:call).with("MIGRATE", host, port, key_name, destination, timeout, "COPY").and_return("OK")
			
			expect(object.migrate(host, port, destination, keys: [key_name], timeout: timeout, copy: true)).to be == "OK"
		end
		
		it "can generate correct arguments with replace option" do
			expect(object).to receive(:call).with("MIGRATE", host, port, key_name, destination, timeout, "REPLACE").and_return("OK")
			
			expect(object.migrate(host, port, destination, keys: [key_name], timeout: timeout, replace: true)).to be == "OK"
		end
		
		it "can generate correct arguments with auth option" do
			auth_value = "password"
			expect(object).to receive(:call).with("MIGRATE", host, port, key_name, destination, timeout, "AUTH", auth_value).and_return("OK")
			
			expect(object.migrate(host, port, destination, keys: [key_name], timeout: timeout, auth: auth_value)).to be == "OK"
		end
		
		it "raises error when no keys provided" do
			expect{object.migrate(host, port, destination, keys: [])}.to raise_exception(ArgumentError, message: be =~ /Must provide keys/)
		end
	end
	
	with "#move" do
		let(:db) {1}
		
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("MOVE", key_name, db).and_return(1)
			
			expect(object.move(key_name, db)).to be == 1
		end
	end
	
	with "#object" do
		let(:subcommand) {"encoding"}
		
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("OBJECT", subcommand, key_name).and_return("embstr")
			
			expect(object.object(subcommand, key_name)).to be == "embstr"
		end
	end
	
	with "#persist" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("PERSIST", key_name).and_return(1)
			
			expect(object.persist(key_name)).to be == 1
		end
	end
	
	with "#pexpire" do
		let(:milliseconds) {60000}
		
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("PEXPIRE", key_name, milliseconds).and_return(1)
			
			expect(object.pexpire(key_name, milliseconds)).to be == 1
		end
	end
	
	with "#pexpireat" do
		let(:milliseconds_timestamp) {(Time.now.to_f * 1000).to_i}
		
		it "can generate correct arguments with integer timestamp" do
			expect(object).to receive(:call).with("PEXPIREAT", key_name, milliseconds_timestamp).and_return(1)
			
			expect(object.pexpireat(key_name, milliseconds_timestamp)).to be == 1
		end
		
		it "can generate correct arguments with Time object" do
			time = Time.at(milliseconds_timestamp / 1000.0)
			expected_timestamp = (time.to_f * 1000).to_i
			expect(object).to receive(:call).with("PEXPIREAT", key_name, expected_timestamp).and_return(1)
			
			expect(object.pexpireat(key_name, time)).to be == 1
		end
	end
	
	with "#pttl" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("PTTL", key_name).and_return(60000)
			
			expect(object.pttl(key_name)).to be == 60000
		end
	end
	
	with "#randomkey" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("RANDOMKEY").and_return(key_name)
			
			expect(object.randomkey).to be == key_name
		end
	end
	
	with "#rename" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("RENAME", key_name, new_key).and_return("OK")
			
			expect(object.rename(key_name, new_key)).to be == "OK"
		end
	end
	
	with "#renamenx" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("RENAMENX", key_name, new_key).and_return(1)
			
			expect(object.renamenx(key_name, new_key)).to be == 1
		end
	end
	
	with "#restore" do
		let(:serialized_value) {"\x00\x05hello\t\x00\xF7\x02\x11\x00\x00\x00"}
		let(:ttl) {0}
		
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("RESTORE", key_name, ttl, serialized_value).and_return("OK")
			
			expect(object.restore(key_name, serialized_value, ttl)).to be == "OK"
		end
	end
	
	with "#scan" do
		let(:cursor) {0}
		
		it "can generate correct arguments with cursor only" do
			expect(object).to receive(:call).with("SCAN", cursor).and_return([0, [key_name]])
			
			expect(object.scan(cursor)).to be == [0, [key_name]]
		end
		
		it "can generate correct arguments with match option" do
			expect(object).to receive(:call).with("SCAN", cursor, "MATCH", pattern).and_return([0, [key_name]])
			
			expect(object.scan(cursor, match: pattern)).to be == [0, [key_name]]
		end
		
		it "can generate correct arguments with count option" do
			count = 10
			expect(object).to receive(:call).with("SCAN", cursor, "COUNT", count).and_return([0, [key_name]])
			
			expect(object.scan(cursor, count: count)).to be == [0, [key_name]]
		end
		
		it "can generate correct arguments with type option" do
			type = "string"
			expect(object).to receive(:call).with("SCAN", cursor, "TYPE", type).and_return([0, [key_name]])
			
			expect(object.scan(cursor, type: type)).to be == [0, [key_name]]
		end
		
		it "can generate correct arguments with all options" do
			count = 10
			type = "string"
			expect(object).to receive(:call).with("SCAN", cursor, "MATCH", pattern, "COUNT", count, "TYPE", type).and_return([0, [key_name]])
			
			expect(object.scan(cursor, match: pattern, count: count, type: type)).to be == [0, [key_name]]
		end
	end
	
	with "#sort" do
		it "can generate correct arguments with key only" do
			expect(object).to receive(:call).with("SORT", key_name, "ASC").and_return([value])
			
			expect(object.sort(key_name)).to be == [value]
		end
		
		it "can generate correct arguments with by option" do
			by_pattern = "weight_*"
			expect(object).to receive(:call).with("SORT", key_name, "BY", by_pattern, "ASC").and_return([value])
			
			expect(object.sort(key_name, by: by_pattern)).to be == [value]
		end
		
		it "can generate correct arguments with limit options" do
			offset = 0
			count = 5
			expect(object).to receive(:call).with("SORT", key_name, "LIMIT", offset, count, "ASC").and_return([value])
			
			expect(object.sort(key_name, offset: offset, count: count)).to be == [value]
		end
		
		it "can generate correct arguments with get option" do
			get_patterns = ["object_*", "#"]
			expect(object).to receive(:call).with("SORT", key_name, "GET", "object_*", "GET", "#", "ASC").and_return([value])
			
			expect(object.sort(key_name, get: get_patterns)).to be == [value]
		end
		
		it "can generate correct arguments with desc order" do
			expect(object).to receive(:call).with("SORT", key_name, "DESC").and_return([value])
			
			expect(object.sort(key_name, order: "DESC")).to be == [value]
		end
		
		it "can generate correct arguments with alpha option" do
			expect(object).to receive(:call).with("SORT", key_name, "ASC", "ALPHA").and_return([value])
			
			expect(object.sort(key_name, alpha: true)).to be == [value]
		end
		
		it "can generate correct arguments with store option" do
			store_key = "sorted_key"
			expect(object).to receive(:call).with("SORT", key_name, "ASC", "STORE", store_key).and_return(1)
			
			expect(object.sort(key_name, store: store_key)).to be == 1
		end
	end
	
	with "#touch" do
		it "can generate correct arguments with single key" do
			expect(object).to receive(:call).with("TOUCH", key_name).and_return(1)
			
			expect(object.touch(key_name)).to be == 1
		end
		
		it "can generate correct arguments with multiple keys" do
			expect(object).to receive(:call).with("TOUCH", key_name, key_name2).and_return(2)
			
			expect(object.touch(key_name, key_name2)).to be == 2
		end
	end
	
	with "#ttl" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("TTL", key_name).and_return(60)
			
			expect(object.ttl(key_name)).to be == 60
		end
	end
	
	with "#type" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("TYPE", key_name).and_return("string")
			
			expect(object.type(key_name)).to be == "string"
		end
	end
	
	with "#unlink" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("UNLINK", key_name).and_return(1)
			
			expect(object.unlink(key_name)).to be == 1
		end
	end
	
	with "#wait" do
		let(:numreplicas) {2}
		let(:timeout) {1000}
		
		it "can generate correct arguments with default timeout" do
			expect(object).to receive(:call).with("WAIT", numreplicas, 0).and_return(2)
			
			expect(object.wait(numreplicas)).to be == 2
		end
		
		it "can generate correct arguments with custom timeout" do
			expect(object).to receive(:call).with("WAIT", numreplicas, timeout).and_return(2)
			
			expect(object.wait(numreplicas, timeout)).to be == 2
		end
	end
end
