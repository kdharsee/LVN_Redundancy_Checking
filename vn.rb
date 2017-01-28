require './block'

class LVN
  attr_reader :orig, :unneeded

  def initialize(stmts)
    @n2v, @orig = Hash.new, stmts
    @last_val = 0
    @unneeded = [ ]
    run_lvn
  end

  private
  def vn_search_add( str )
    return @n2v[str], true if @n2v[str] != nil
    # str is not in n2v
    vn_add( str )
    return @last_val, false
  end

  def vn_add( str )
    @last_val = @last_val + 1 # Create a new VN
    @n2v[str] = @last_val # Give str the new VN, add it to the table
    # Check if str has multiple notations via commutivity
    # Find any commutative operators
    i = str.index('*') if not i = str.index('+')
    # Reverse operands for commutative ops
    @n2v[str[i+1,-1] + str[i] + str[0,i-1]] = @last_val if i != nil
  end
    

  def vn_copy_stmt( s )
    v, found = vn_search_add( s.op1 )
    v2, found = vn_search_add( s.lhs )
    if v2 == v
      @unneeded << s
    else
      @n2v[ s.lhs ] = v
    end
  end
    
  def vn_expr_stmt( s )
    v1, found = vn_search_add( s.op1 )
    v2, found = vn_search_add( s.op2 )
    expr = [v1, s.op, v2] * ' '
    v3, found = vn_search_add( expr )
    if found 
      if v3 == @n2v[ s.lhs ]
        puts "#{s} is redundant"
      else
        puts "#{[s.op1, s.op, s.op2] * ' '} is redundant"
      end
      @unneeded << s
    end
    @n2v[ s.lhs ] = v3
  end

  def run_lvn
    @orig.code.each do |s|
      puts "analyze #{s}"
      if s.op == nil
        vn_copy_stmt( s )
      else
        vn_expr_stmt( s )
      end
    end
  end

end
