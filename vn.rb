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


  def vn_add_commutative( str, operand1, op, operand2  )
    # Reverse operands for commutative ops
    if (op == '*') or (op == '+')
      rev_op_str = [operand1, op, operand2] * ' '
      # Add Reversed operands to VN table
      @n2v[rev_op_str] = @last_val
    end
  end


  def vn_add_equiv( str, operand1, op, operand2 )
    # Construct all equivalent relations from VN Table
    case op
    when "+"
      # We have operand1 + operand2 = last_val
      # last_val - operand1 = operand2
      equiv_str = [@last_val, '-', operand1] * ' '
      @n2v[equiv_str] = operand2.to_i
      # last_val - operand2 = operand1
      equiv_str = [@last_val, '-', operand2] * ' '
      @n2v[equiv_str] = operand1.to_i
    when "*"
      # We have operand1 * operand2 = last_val
      # last_val / operand1 = operand2
      equiv_str = [@last_val, '/', operand1] * ' '
      @n2v[equiv_str] = operand2.to_i
      # last_val / operand2 = operand1
      equiv_str = [@last_val, '/', operand2] * ' '
      @n2v[equiv_str] = operand1.to_i
    when "-"
      # We have operand1 - operand2 = last_val
      # last_val + operand2 = operand1
      equiv_str = [@last_val, '+', operand2] * ' '
      @n2v[equiv_str] = operand1.to_i
      vn_add_commutative( equiv_str )
      # operand1 - last_val = operand2
      equiv_str = [operand1, '-',@last_val] * ' '
      @n2v[equiv_str] = operand2.to_i
    when "/"
      # We have operand1 / operand2 = last_val
      # last_val * operand2 = operand1
      equiv_str = [@last_val, '*', operand2] * ' '
      @n2v[equiv_str] = operand1.to_i
      vn_add_commutative( equiv_str )
      # operand1 / last_val = operand2
      equiv_str = [operand1, '/',@last_val] * ' '
      @n2v[equiv_str] = operand2.to_i
    end
  end


  def vn_add( str )
    @last_val = @last_val + 1 # Create a new VN
    @n2v[str] = @last_val # Give str the new VN, add it to the VN table
    i = str.index('*') if not i = str.index('+')
    if i != nil
      operand1 = str[i+1..-1].strip
      operand2 = str[0..i-1].strip
      op = str[i].strip
      # Add commutative op representations to VN table
      vn_add_commutative( str, operand1, op, operand2 )
      # Add equivalent representations to VN table
      vn_add_equiv( str, operand1, op, operand2 )
    end
  end
    

  def vn_copy_stmt( s )
    v, found = vn_search_add( s.op1 )
    v2, found = vn_search_add( s.lhs )
    if v2 == v
      @unneeded << s
    else
      @n2v[ s.lhs ] = v
      puts "#{s}"
    end
  end
    
  def vn_expr_stmt( s )
    v1, found = vn_search_add( s.op1 )
    v2, found = vn_search_add( s.op2 )
    expr = [v1, s.op, v2] * ' '
    v3, found = vn_search_add( expr )
    equiv_expr = s.to_s
    if found 
      if v3 == @n2v[ s.lhs ]
        #puts "#{s} is redundant"
      else
        #puts "#{[s.op1, s.op, s.op2] * ' '} is redundant"
        # Transform statement to equivalent expression
        # Search the VN Table for v3 equivalent label with no op
        rhs = @n2v.map{ |k,v| ((v==v3) and (k.index(/[+\-*\/]/) == nil)) ? k : nil }.compact[0]
        equiv_expr = [s.lhs, '=', rhs] * ' '
        puts "#{equiv_expr}"
      end
      @unneeded << s
    else
      puts "#{equiv_expr}"
    end
    @n2v[ s.lhs ] = v3
    
  end


  def run_lvn
    @orig.code.each do |s|
      #puts "analyze #{s}"
      if s.op == nil
        vn_copy_stmt( s )
      else
        vn_expr_stmt( s )
      end
    end
  end

end
