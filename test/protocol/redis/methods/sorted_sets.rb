# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020, by Dimitry Chopey.
# Copyright, 2020-2026, by Samuel Williams.

require "protocol/redis/methods_context"
require "protocol/redis/methods/sorted_sets"

describe Protocol::Redis::Methods::SortedSets do
	include_context Protocol::Redis::MethodsContext, Protocol::Redis::Methods::SortedSets
	
	let(:set_name) {"test"}
	let(:set_name2) {"test2"}
	let(:dest_set) {"dest"}
	let(:member) {"member1"}
	let(:member2) {"member2"}
	let(:score) {10.5}
	let(:score2) {20.0}
	let(:timeout) {5}
	
	with "#bzpopmin" do
		it "can generate correct arguments with single key" do
			expect(object).to receive(:call).with("BZPOPMIN", set_name, 0).and_return([set_name, member, score])
			
			expect(object.bzpopmin(set_name)).to be == [set_name, member, score]
		end
		
		it "can generate correct arguments with multiple keys and timeout" do
			expect(object).to receive(:call).with("BZPOPMIN", set_name, set_name2, timeout).and_return([set_name, member, score])
			
			expect(object.bzpopmin(set_name, set_name2, timeout: timeout)).to be == [set_name, member, score]
		end
	end
	
	with "#bzpopmax" do
		it "can generate correct arguments with single key" do
			expect(object).to receive(:call).with("BZPOPMAX", set_name, 0).and_return([set_name, member, score])
			
			expect(object.bzpopmax(set_name)).to be == [set_name, member, score]
		end
		
		it "can generate correct arguments with multiple keys and timeout" do
			expect(object).to receive(:call).with("BZPOPMAX", set_name, set_name2, timeout).and_return([set_name, member, score])
			
			expect(object.bzpopmax(set_name, set_name2, timeout: timeout)).to be == [set_name, member, score]
		end
	end
	
	with "#zadd" do
		let(:timestamp) {Time.now.to_f}
		
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("ZADD", set_name, timestamp, "payload")
			
			object.zadd(set_name, timestamp, "payload")
		end
		
		it "can generate correct arguments with options" do
			expect(object).to receive(:call).with("ZADD", set_name, "XX", "CH", "INCR", timestamp, "payload")
			
			object.zadd(set_name, timestamp, "payload", update: true, change: true, increment: true)
		end
		
		it "can generate correct multiple arguments" do
			expect(object).to receive(:call).with("ZADD", set_name, "XX", "CH", "INCR", timestamp, "payload-1", timestamp, "payload-2")
			
			object.zadd(set_name, timestamp, "payload-1", timestamp, "payload-2", update: true, change: true, increment: true)
		end
		
		it "can generate correct arguments with NX update option" do
			expect(object).to receive(:call).with("ZADD", set_name, "NX", timestamp, "payload")
			
			object.zadd(set_name, timestamp, "payload", update: false)
		end
	end
	
	with "#zcard" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("ZCARD", set_name).and_return(5)
			
			expect(object.zcard(set_name)).to be == 5
		end
	end
	
	with "#zcount" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("ZCOUNT", set_name, 0, 10).and_return(3)
			
			expect(object.zcount(set_name, 0, 10)).to be == 3
		end
	end
	
	with "#zincrby" do
		let(:increment) {5.5}
		
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("ZINCRBY", set_name, increment, member).and_return("16.0")
			
			expect(object.zincrby(set_name, increment, member)).to be == "16.0"
		end
	end
	
	with "#zinterstore" do
		it "can generate correct arguments with basic parameters" do
			expect(object).to receive(:call).with("ZINTERSTORE", dest_set, 2, set_name, set_name2).and_return(3)
			
			expect(object.zinterstore(dest_set, [set_name, set_name2])).to be == 3
		end
		
		it "can generate correct arguments with weights" do
			weights = [2, 3]
			expect(object).to receive(:call).with("ZINTERSTORE", dest_set, 2, set_name, set_name2, "WEIGHTS", 2, 3).and_return(3)
			
			expect(object.zinterstore(dest_set, [set_name, set_name2], weights)).to be == 3
		end
		
		it "can generate correct arguments with aggregate" do
			expect(object).to receive(:call).with("ZINTERSTORE", dest_set, 2, set_name, set_name2, "AGGREGATE", "MIN").and_return(3)
			
			expect(object.zinterstore(dest_set, [set_name, set_name2], nil, aggregate: "MIN")).to be == 3
		end
		
		it "raises error when weights size doesn't match keys size" do
			weights = [2]
			expect{object.zinterstore(dest_set, [set_name, set_name2], weights)}.to raise_exception(ArgumentError, message: be =~ /weights given/)
		end
	end
	
	with "#zlexcount" do
		let(:min) {"[a"}
		let(:max) {"[z"}
		
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("ZLEXCOUNT", set_name, min, max).and_return(5)
			
			expect(object.zlexcount(set_name, min, max)).to be == 5
		end
	end
	
	with "#zpopmax" do
		it "can generate correct arguments with default count" do
			expect(object).to receive(:call).with("ZPOPMAX", set_name, 1).and_return([member, score])
			
			expect(object.zpopmax(set_name)).to be == [member, score]
		end
		
		it "can generate correct arguments with custom count" do
			count = 3
			expect(object).to receive(:call).with("ZPOPMAX", set_name, count).and_return([member, score, member2, score2])
			
			expect(object.zpopmax(set_name, count)).to be == [member, score, member2, score2]
		end
	end
	
	with "#zpopmin" do
		it "can generate correct arguments with default count" do
			expect(object).to receive(:call).with("ZPOPMIN", set_name, 1).and_return([member, score])
			
			expect(object.zpopmin(set_name)).to be == [member, score]
		end
		
		it "can generate correct arguments with custom count" do
			count = 3
			expect(object).to receive(:call).with("ZPOPMIN", set_name, count).and_return([member, score, member2, score2])
			
			expect(object.zpopmin(set_name, count)).to be == [member, score, member2, score2]
		end
	end
	
	with "#zrange" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("ZRANGE", set_name, 0, 0)
			
			object.zrange(set_name, 0, 0)
		end
		
		it "can generate correct arguments with options" do
			expect(object).to receive(:call).with("ZRANGE", set_name, 0, 0, "WITHSCORES")
			
			object.zrange(set_name, 0, 0, with_scores: true)
		end
	end
	
	with "#zrangebylex" do
		let(:min) {"[a"}
		let(:max) {"[z"}
		
		it "can generate correct arguments without limit" do
			expect(object).to receive(:call).with("ZRANGEBYLEX", set_name, min, max).and_return([member, member2])
			
			expect(object.zrangebylex(set_name, min, max)).to be == [member, member2]
		end
		
		it "can generate correct arguments with limit" do
			limit = [0, 10]
			expect(object).to receive(:call).with("ZRANGEBYLEX", set_name, min, max, "LIMIT", 0, 10).and_return([member])
			
			expect(object.zrangebylex(set_name, min, max, limit: limit)).to be == [member]
		end
	end
	
	with "#zrevrangebylex" do
		let(:min) {"[a"}
		let(:max) {"[z"}
		
		it "can generate correct arguments without limit" do
			expect(object).to receive(:call).with("ZREVRANGEBYLEX", set_name, min, max).and_return([member2, member])
			
			expect(object.zrevrangebylex(set_name, min, max)).to be == [member2, member]
		end
		
		it "can generate correct arguments with limit" do
			limit = [0, 10]
			expect(object).to receive(:call).with("ZREVRANGEBYLEX", set_name, min, max, "LIMIT", 0, 10).and_return([member])
			
			expect(object.zrevrangebylex(set_name, min, max, limit: limit)).to be == [member]
		end
	end
	
	with "#zrangebyscore" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("ZRANGEBYSCORE", set_name, 0, 0)
			
			object.zrangebyscore(set_name, 0, 0)
		end
		
		it "can generate correct arguments with WITHSCORES options" do
			expect(object).to receive(:call).with("ZRANGEBYSCORE", set_name, 0, 0, "WITHSCORES")
			
			object.zrangebyscore(set_name, 0, 0, with_scores: true)
		end
		
		it "can generate correct arguments with WITHSCORES options" do
			expect(object).to receive(:call).with("ZRANGEBYSCORE", set_name, 0, 0, "WITHSCORES", "LIMIT", 0, 10)
			
			object.zrangebyscore(set_name, 0, 0, with_scores: true, limit: [0, 10])
		end
	end
	
	with "#zrank" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("ZRANK", set_name, member).and_return(0)
			
			expect(object.zrank(set_name, member)).to be == 0
		end
	end
	
	with "#zrem" do
		let(:member_name) {"test_member"}
		
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("ZREM", set_name, member_name)
			
			object.zrem(set_name, member_name)
		end
	end
	
	with "#zremrangebylex" do
		let(:min) {"[a"}
		let(:max) {"[z"}
		
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("ZREMRANGEBYLEX", set_name, min, max).and_return(3)
			
			expect(object.zremrangebylex(set_name, min, max)).to be == 3
		end
	end
	
	with "#zremrangebyrank" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("ZREMRANGEBYRANK", set_name, 0, 2).and_return(3)
			
			expect(object.zremrangebyrank(set_name, 0, 2)).to be == 3
		end
	end
	
	with "#zremrangebyscore" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("ZREMRANGEBYSCORE", set_name, 0, 10).and_return(2)
			
			expect(object.zremrangebyscore(set_name, 0, 10)).to be == 2
		end
	end
	
	with "#zrevrange" do
		it "can generate correct arguments without scores" do
			expect(object).to receive(:call).with("ZREVRANGE", set_name, 0, -1).and_return([member2, member])
			
			expect(object.zrevrange(set_name, 0, -1)).to be == [member2, member]
		end
		
		it "can generate correct arguments with scores" do
			expect(object).to receive(:call).with("ZREVRANGE", set_name, 0, -1, "WITHSCORES").and_return([member2, score2, member, score])
			
			expect(object.zrevrange(set_name, 0, -1, with_scores: true)).to be == [member2, score2, member, score]
		end
	end
	
	with "#zrevrangebyscore" do
		it "can generate correct arguments without options" do
			expect(object).to receive(:call).with("ZREVRANGEBYSCORE", set_name, 10, 0).and_return([member2, member])
			
			expect(object.zrevrangebyscore(set_name, 10, 0)).to be == [member2, member]
		end
		
		it "can generate correct arguments with scores" do
			expect(object).to receive(:call).with("ZREVRANGEBYSCORE", set_name, 10, 0, "WITHSCORES").and_return([member2, score2, member, score])
			
			expect(object.zrevrangebyscore(set_name, 10, 0, with_scores: true)).to be == [member2, score2, member, score]
		end
		
		it "can generate correct arguments with limit" do
			limit = [0, 5]
			expect(object).to receive(:call).with("ZREVRANGEBYSCORE", set_name, 10, 0, "LIMIT", 0, 5).and_return([member])
			
			expect(object.zrevrangebyscore(set_name, 10, 0, limit: limit)).to be == [member]
		end
	end
	
	with "#zrevrank" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("ZREVRANK", set_name, member).and_return(1)
			
			expect(object.zrevrank(set_name, member)).to be == 1
		end
	end
	
	with "#zscore" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("ZSCORE", set_name, member).and_return(score.to_s)
			
			expect(object.zscore(set_name, member)).to be == score.to_s
		end
	end
	
	with "#zunionstore" do
		it "can generate correct arguments" do
			expect(object).to receive(:call).with("ZUNIONSTORE", dest_set, set_name, set_name2).and_return(5)
			
			expect(object.zunionstore(dest_set, set_name, set_name2)).to be == 5
		end
	end
	
	with "#zscan" do
		let(:cursor) {0}
		
		it "can generate correct arguments with cursor only" do
			expect(object).to receive(:call).with("ZSCAN", set_name, cursor).and_return([0, [member, score]])
			
			expect(object.zscan(set_name, cursor)).to be == [0, [member, score]]
		end
		
		it "can generate correct arguments with match option" do
			match_pattern = "test*"
			expect(object).to receive(:call).with("ZSCAN", set_name, cursor, "MATCH", match_pattern).and_return([0, [member, score]])
			
			expect(object.zscan(set_name, cursor, match: match_pattern)).to be == [0, [member, score]]
		end
		
		it "can generate correct arguments with count option" do
			count = 10
			expect(object).to receive(:call).with("ZSCAN", set_name, cursor, "COUNT", count).and_return([0, [member, score]])
			
			expect(object.zscan(set_name, cursor, count: count)).to be == [0, [member, score]]
		end
		
		it "can generate correct arguments with all options" do
			match_pattern = "test*"
			count = 10
			expect(object).to receive(:call).with("ZSCAN", set_name, cursor, "MATCH", match_pattern, "COUNT", count).and_return([0, [member, score]])
			
			expect(object.zscan(set_name, cursor, match: match_pattern, count: count)).to be == [0, [member, score]]
		end
	end
end
