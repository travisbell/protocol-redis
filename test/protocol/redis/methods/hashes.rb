# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Troex Nevelin.
# Copyright, 2023-2026, by Samuel Williams.
# Copyright, 2023, by Nick Burwell.

require "protocol/redis/methods_context"
require "protocol/redis/methods/hashes"

describe Protocol::Redis::Methods::Hashes do
	include_context Protocol::Redis::MethodsContext, Protocol::Redis::Methods::Hashes
	
	let(:hash_name) {"htest"}
	let(:field_name) {"field"}
	let(:field2_name) {"field2"}
	let(:value) {"value"}
	let(:value2) {"value2"}
	
	with "#hlen" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("HLEN", hash_name).and_return(2)
			
			expect(object.hlen(hash_name)).to be == 2
		end
	end
	
	with "#hset" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("HSET", hash_name, field_name, value).and_return(1)
			
			expect(object.hset(hash_name, field_name, value)).to be == 1
		end
	end
	
	with "#hsetnx" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("HSETNX", hash_name, field_name, value).and_return(1)
			
			expect(object.hsetnx(hash_name, field_name, value)).to be == true
		end
	end
	
	with "#hmset" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("HMSET", hash_name, field_name, value).and_return("OK")
			
			expect(object.hmset(hash_name, field_name, value)).to be == "OK"
		end
	end
	
	with "#mapped_hmset" do
		it "can generate correct arguments from a hash" do
			expect(object).to receive(:call).with("HMSET", hash_name, field_name, value).and_return("OK")
			
			expect(object.mapped_hmset(hash_name, { field_name => value })).to be == "OK"
		end
	end
	
	with "#hget" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("HGET", hash_name, field_name).and_return(value)
			
			expect(object.hget(hash_name, field_name)).to be == value
		end
	end
	
	with "#hmget" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("HMGET", hash_name, field_name, field2_name).and_return([value, value2])
			
			expect(object.hmget(hash_name, field_name, field2_name)).to be == [value, value2]
		end
	end
	
	with "#mapped_hmget" do
		it "can generate correct arguments and return hash" do
			expect(object).to receive(:call).with("HMGET", hash_name, field_name, field2_name).and_return([value, value2])
			
			expect(object.mapped_hmget(hash_name, field_name, field2_name)).to be == {
				field_name => value,
				field2_name => value2
			}
		end
	end
	
	with "#hdel" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("HDEL", hash_name, field_name, field2_name).and_return(2)
			
			expect(object.hdel(hash_name, field_name, field2_name)).to be == 2
		end
	end
	
	with "#hexists" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("HEXISTS", hash_name, field_name).and_return(1)
			
			expect(object.hexists(hash_name, field_name)).to be == true
		end
	end
	
	with "#hincrby" do
		let(:increment) {5}
		
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("HINCRBY", hash_name, field_name, increment).and_return(10)
			
			expect(object.hincrby(hash_name, field_name, increment)).to be == 10
		end
	end
	
	with "#hincrbyfloat" do
		let(:value) {3.14}
		
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("HINCRBYFLOAT", hash_name, field_name, value).and_return("3.1400000000000001")
			
			expect(object.hincrbyfloat(hash_name, field_name, value)).to be == value
		end
	end
	
	with "#hkeys" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("HKEYS", hash_name).and_return([field_name, field2_name])
			
			expect(object.hkeys(hash_name)).to be == [field_name, field2_name]
		end
	end
	
	with "#hvals" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("HVALS", hash_name).and_return([value, value2])
			
			expect(object.hvals(hash_name)).to be == [value, value2]
		end
	end
	
	with "#hgetall" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("HGETALL", hash_name).and_return([field_name, value, "test", "1"])
			
			expect(object.hgetall(hash_name)).to be == {field_name => value, "test" => "1"}
		end
		
		it "returns nil when call returns nil (e.g., in pipeline)" do
			expect(object).to receive(:call).with("HGETALL", hash_name).and_return(nil)
			
			expect(object.hgetall(hash_name)).to be_nil
		end
	end
	
	with "#hscan" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("HSCAN", hash_name, 0).and_return([0, []])
			
			expect(object.hscan(hash_name, 0)).to be == [0, []]
		end
		
		it "can generate correct arguments with options" do
			expect(object).to receive(:call).with("HSCAN", hash_name, "0", "MATCH", "test*", "COUNT", 10).and_return(["0", []])
			
			expect(object.hscan(hash_name, "0", match: "test*", count: 10)).to be == ["0", []]
		end
	end
	
	with "#hscan_each" do
		it "can iterate through hash fields and stops when cursor is 0" do
			expect(object).to receive(:hscan).with(hash_name, "0", match: nil, count: nil).and_return(["0", [field_name, value, field2_name, value2]])
			
			collected = []
			object.hscan_each(hash_name) do |field, val|
				collected << [field, val]
			end
			
			expect(collected).to be == [[field_name, value], [field2_name, value2]]
		end
		
		it "returns enumerator when no block given" do
			enumerator = object.hscan_each(hash_name)
			expect(enumerator).to be_a(Enumerator)
		end
		
		it "can generate correct arguments with options" do
			expect(object).to receive(:hscan).with(hash_name, "0", match: "test*", count: 10).and_return(["0", []])
			
			object.hscan_each(hash_name, "0", match: "test*", count: 10){}
		end
	end
end
