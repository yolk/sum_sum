SumSum
=============

SumSum allows you to generate simple reports on the count of values in hashes.

Installation
-------

    gem install sum_sum


Basic Usage
-------

    sum_sum = SumSum.new(:type, :name, :version)
    
    sum_sum.add(:type => :Browser, :name => :Firefox, :version => "3.6.13")
    sum_sum.add(:type => :Browser, :name => :Safari, :version => "5.0.3")
    sum_sum.add(:type => :Browser, :name => :Firefox, :version => "3.6.12")
    sum_sum.add(:type => :Browser, :name => :Chrome, :version => "5.0")
    
    sum[:Browser].count
    => 4
    sum[:Browser].keys
    => [:Firefox, :Safari, :Chrome]
    sum[:Browser][:Firefox].count
    => 2
    sum[:Browser][:Firefox].share
    => 0.5
    sum[:Browser][:Firefox]["3.6.13"].share
    => 0.5
    

BlaBla
-------

Copyright (c) <%= Date.today.year %> Yolk Sebastian Munz & Julia Soergel GbR

Beyond that, the implementation is licensed under the MIT License.