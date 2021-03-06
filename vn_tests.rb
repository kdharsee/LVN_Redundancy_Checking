require_relative 'block.rb'
require_relative 'vn.rb'

module TestProgs
  def progs_n_answers
    @answers = Hash.new{ |hash, key| hash[key] = Array.new }

    @trivial = Block.new( "trivial" ) do |b|
      s1 = Stmt.new( "a", "b", "+", "c" )
      s2 = Stmt.new( "a", "b", "+", "c" )
      b.code << s1 << s2
      @answers[b] << s2
    end

    @cocke_allen = Block.new( "Cocke Allen 1971" ) do |b|
      s1 = Stmt.new( "x", "a", "*", "b" )
      s2 = Stmt.new( "c", "a" )
      s3 = Stmt.new( "y", "c", "*", "b" )
      b.code << s1 << s2 << s3
      @answers[b] << s3
    end

    @tricky = Block.new( "tricky" ) do |b|
      s1 = Stmt.new( "a", "b", "+", "c" )
      s2 = Stmt.new( "a", "c", "+", "b" )
      b.code << s1 << s2
      @answers[b] << s2
    end

    @intricate = Block.new( "stewart" ) do |b|
      s1 = Stmt.new( "e", "f", "+", "g" )
      s2 = Stmt.new( "h", "e", "-", "f" )
      b.code << s1 << s2
      @answers[b] << s2
    end
  end
end

describe LVN do
  include TestProgs

  before do
    progs_n_answers
  end

  it "trivial case" do
    expect( LVN.new( @trivial ).unneeded ).to eq( @answers[@trivial] )
  end

  it "cocke-allen 1971" do
    expect( LVN.new( @cocke_allen ).unneeded ).to eq( @answers[@cocke_allen] )
  end

  it "tricky" do
    expect( LVN.new( @tricky ).unneeded ).to eq( @answers[@tricky] )
  end

  it "Chrisopher Charles Stewart" do
    expect( LVN.new( @intricate ).unneeded ).to eq( @answers[@intricate] )
  end
end


