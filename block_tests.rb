require_relative 'block'

module S12
  def setup
    @s1 = Stmt.new( "a", "b" )
    @s2 = Stmt.new( "c", "d", "-", "e" )
    @c1 = "a = b"
    @c2 = "c = d - e"
  end
end

describe Block do
  include S12
  
  before do
    setup
  end

  it "statement code gen" do
    expect(@s1.gen_code).to eq( @c1 )
    expect(@s2.gen_code).to eq( @c2 )
  end

  it "block code gen" do
    basic = Block.new do |b|
      b.code << @s1 << @s2
    end

    expect(basic.to_s).to eq( "// code block \n#{@c1}\n#{@c2}\n" )
  end
end
