require 'spec_helper'

describe SumSum do
  context ".new" do
    it "should raise no error with zero argument" do
      lambda{ SumSum.new }.should_not raise_error(ArgumentError)
    end
    
    it "should raise no error with one argument" do
      lambda{ SumSum.new(:x) }.should_not raise_error
    end
    
    it "should raise no error with multiple argument" do
      lambda{ SumSum.new(:x, :y, :z) }.should_not raise_error
    end
  end
  
  let(:sum) { SumSum.new(:type, :name, :version) }
  
  context "adding single hash" do
    before do
      sum.add({:type => :Browser, :name => :Firefox, :version => "3.6.0"})
    end
    
    context "#count" do
      it "should return 1 on all levels" do
        sum.count.should eql(1)
        sum[:Browser].count.should eql(1)
        sum[:Browser][:Firefox].count.should eql(1)
        sum[:Browser][:Firefox]["3.6.0"].count.should eql(1)
      end
    end
    
    context "#keys" do
      it "should return correct keys on all levels" do
        sum.keys.should eql([:Browser])
        sum[:Browser].keys.should eql([:Firefox])
        sum[:Browser][:Firefox].keys.should eql(["3.6.0"])
        sum[:Browser][:Firefox]["3.6.0"].keys.should eql([])
      end
    end
    
    context "#dump" do
      it "should output serializable array" do
        sum.dump.should eql(
          [[:type, :name, :version], {:Browser=>{:Firefox=>{"3.6.0"=>1}}}]
        )
      end
    end
    
    context ".load" do
      it "should restore everything from serializable array" do
        SumSum.load(sum.dump).dump.should eql(sum.dump)
      end
    end
  
    context "#level" do
      it "should return 0 on root" do
        sum.level.should eql(0)
      end
      
      it "should return correct level on children" do
        sum[:Browser].level.should eql(1)
        sum[:Browser][:Firefox].level.should eql(2)
        sum[:Browser][:Firefox]["3.6.0"].level.should eql(3)
      end
    end
  end
  
  context "adding multiple hashes" do
    before do
      sum.add({:type => :Crawler, :name => :GoogleBot, :version => "2.0"})
      sum.add({:type => :Browser, :name => :Firefox, :version => "3.6.0"})
      sum.add({:type => :Browser, :name => :Safari, :version => "4.0"})
      sum.add({:type => :Browser, :name => :Safari, :version => "5.0"})
      sum.add({:type => :Browser, :name => :Safari, :version => "5.0"})
    end
    
    context "#add" do
      it "should return itself" do
        sum.add({:type => :Crawler, :name => :GoogleBot, :version => "2.0"}).should eql(sum)
      end
      
      it "should add missing values as nil" do
        sum.add({:type => :Crawler, :name => nil})
        sum.add({:type => :Crawler})
        
        sum[:Crawler].keys.should eql([:GoogleBot, nil])
        sum[:Crawler][nil].count.should eql(2)
        sum[:Crawler][nil].keys.should eql([nil])
        sum[:Crawler][nil][nil].count.should eql(2)
      end
      
      it "should allow to add multiple counts at once" do
        sum.add({:type => :Crawler, :name => :DuckDuckGo, :version => "1.0"}, 10)
        
        sum[:Crawler].count.should eql(11)
        sum[:Crawler][:DuckDuckGo].count.should eql(10)
        sum[:Crawler][:DuckDuckGo]["1.0"].count.should eql(10)
      end
    end
    
    context "#count" do
      it "should return correct count on all levels" do
        sum.count.should eql(5)
        
        sum[:Browser].count.should eql(4)
        sum[:Browser][:Firefox].count.should eql(1)
        sum[:Browser][:Firefox]["3.6.0"].count.should eql(1)
        sum[:Browser][:Safari].count.should eql(3)
        sum[:Browser][:Safari]["5.0"].count.should eql(2)
        sum[:Browser][:Safari]["4.0"].count.should eql(1)
        
        sum[:Crawler].count.should eql(1)
        sum[:Crawler][:GoogleBot].count.should eql(1)
        sum[:Crawler][:GoogleBot]["2.0"].count.should eql(1)
      end
    end
    
    context "#keys" do
      it "should return correct keys on all levels" do
        sum.keys.should eql([:Crawler, :Browser])
        sum[:Browser].keys.should eql([:Firefox, :Safari])
        sum[:Browser][:Firefox].keys.should eql(["3.6.0"])
        sum[:Browser][:Firefox]["3.6.0"].keys.should eql([])
        sum[:Browser][:Safari].keys.should eql(["4.0", "5.0"])
        sum[:Browser][:Safari]["4.0"].keys.should eql([])
        sum[:Browser][:Safari]["5.0"].keys.should eql([])
        sum[:Crawler].keys.should eql([:GoogleBot])
        sum[:Crawler][:GoogleBot].keys.should eql(["2.0"])
        sum[:Crawler][:GoogleBot]["2.0"].keys.should eql([])
      end
    end
    
    context "#sort" do
      before do
        sum.add({:type => :Browser, :name => :Safari, :version => "5.0.3"}, 3)
        sum.add({:type => :Browser, :name => :Chrome, :version => "5.0"}, 2)
        sum.sort!
      end
      
      it "should sort by count" do
        sum.keys.should eql([:Browser, :Crawler])
        sum[:Browser].keys.should eql([:Safari, :Chrome, :Firefox])
        sum[:Browser][:Safari].keys.should eql(["5.0.3", "5.0", "4.0"])
      end
    end
    
    context "#share" do
      it "should return 1.0 on root" do
        sum.share.should eql(1.0)
      end
      
      it "should return 1.0 on branch with single entry" do
        sum[:Crawler][:GoogleBot].share.should eql(1.0)
      end
      
      it "should return 0.2 on branch with one out of five" do
        sum[:Crawler].share.should eql(0.2)
      end
      
      it "should return 0.8 on branch with four out of five" do
        sum[:Browser].share.should eql(0.8)
      end
      
      it "should return 0.25 on branch with one out of four" do
        sum[:Browser][:Firefox].share.should eql(0.25)
      end
    end
  
    context "#dump" do
      it "should output serializable array" do
        sum.dump.should eql(
          [[:type, :name, :version], {
            :Crawler=>{:GoogleBot=>{"2.0"=>1}}, 
            :Browser=>{
              :Firefox=>{"3.6.0"=>1}, 
              :Safari=>{"4.0"=>1, "5.0"=>2}
            }
          }]
        )
      end
    end
    
    context ".load" do
      it "should restore everything from serializable array" do
        SumSum.load(sum.dump).dump.should eql(sum.dump)
      end
    end
    
  end
end