#!/usr/bin/ruby

class Lexer
  @variables = {}
  @tokens = []
  @point = 0
  
  def initialize(filename)
    @variables = {}
    @tokens = []
    @point = 0
    file = File.open(filename)
    parse(file)
  end

  def parse(file)
    text = file.read
    #remove comments
    while (text =~ /\/\/.*$/)
      text.slice!(/\/\/.*$/)
    end
    #tokenize
    regtokens = /[a-zA-Z][\w\d]*|:=|\+|\-|\*|\(|\)|<=|=|\d+|\/|;|true|false|and|not|skip|if|then|else|while|do/
    @tokens = text.scan(regtokens)
    @tokens.insert(-1,"EOF")
  end

  def print_tokens()
    print @tokens
    print "\n"
  end

  def get_token()
    if (@tokens.size > 0)
      if (@point <= @tokens.size)
        s = @tokens[@point]
        @point = @point+1
        return s
      else
        return nil
      end
    else
      return nil
    end
  end

end

class Parser
  @lexer
  @cs #Current Symbol
  @symbols

  def initialize(lexer)
    @lexer = lexer
    puts "PARSER INITIALIZING"
    puts ''
    get_symbol()
    program
    programend
  end

  def get_symbol()
    token = @lexer.get_token
    print 'current symbol: '
    print token
    case token
    when /^EOF$/
      @cs = "EOF"
    when /^\+$/
      @cs = "plus"
    when /^\-$/
      @cs = "minus"
    when /^<=$/
      @cs = "lteq"
    when /^=$/
      @cs = "equal"
    when /^\*$/
      @cs = "multiply"
    when /^\/$/
      @cs = "divide"
    when /^;$/
      @cs = "break"
    when /^true$/
      @cs = "true"
    when /^false$/
      @cs = "false"
    when /^and$/
      @cs = "and"
    when /^not$/
      @cs = "not"
    when /^if$/
      @cs = "if"
    when /^then$/
      @cs = "then"
    when /^else$/
      @cs = "else"
    when /^while$/
      @cs = "while"
    when /^do$/
      @cs = "do"
    when /^skip$/
      @cs = "skip"
    when /^[a-zA-Z][\w\d]*$/
      @cs = "identifier"
    when /^\($/
      @cs = "leftparen"
    when /^\)$/
      @cs = "rightparen"
    when /^\d+$/
      @cs = "integer"
    when /^;$/
      @cs = ";"
    when /^:=$/
      @cs = "assign"
    else

    end
    print "  \t current symbol: "
    puts @cs
  end

  def accept?(symbol)
    if (symbol == @cs)
      get_symbol()
      return true
    end
    return false
  end

  def match(symbol)
    if (symbol == "EOF")
      puts "Parsed Successfully"
      abort()
    end
    print 'MATCHED   '
    puts symbol
    puts ''
    if (accept? symbol)
      return true
    end
    error("Error: unexpected symbol: #{@cs}")
    return false
  end

  def error(message)
    puts message
    abort()
  end

  def program()
    print 'PROGRAM - '
    if (@cs == 'identifier' or @cs == 'while' or @cs == 'if' or @cs == 'skip')
      stmts
    else
      error("Expected: an identifier or while or if or skip")
    end
  end

  def programend()
    print 'PROGRAMEND - '
    if (@cs == 'EOF')
      match("EOF")
    else
      error("Parse Error: Tokens still remain")
    end
  end

  def stmts()
    print 'STMTS - '
    if (@cs == 'identifier' or @cs == 'while' or @cs == 'if' or @cs == 'skip')
      stmt
      fstmt
    else
      error("Expected: an identifier or while or if or skip")
    end
  end

  def fstmt()
    print 'FSTMT - '
    if (@cs == "break")
      match("break")
      stmts
    elsif (@cs == "rightparen")
      #do nothing
    else
      #do nothing
    end
  end

  def stmt()
    print 'STMT - '
    if (@cs == "identifier")
      match('identifier')
      match('assign')
      expr
    elsif (@cs == "while")
      match('while')
      match('leftparen')
      lexpr
      match('rightparen')
      match('do')
      match('leftparen')
      stmts
      match('rightparen')
    elsif (@cs == 'if')
      match('if')
      match('leftparen')
      lexpr
      match('rightparen')
      match('then')
      match('leftparen')
      stmts
      match('rightparen')
      match('else')
      match('leftparen')
      stmts
      match('rightparen')
    elsif (@cs == 'skip')
      match('skip')
    else
      error('expected and identifier, while, if or skip')
    end
  end

  def expr()
    print 'EXPR - '
    if (@cs == 'leftparen' or @cs == 'identifier' or @cs == 'integer')
      term
      fterm
    else
      error('Expected and expression')
    end
  end

  def fterm()
    print 'FTERM - '
    if (@cs == 'minus' or @cs == 'plus')
      exprs
    elsif (@cs == 'equal' or @cs == 'lteq' or @cs == 'and' or @cs == 'rightparen' or @cs == 'break')
      #do nothing
    else
      #do nothing
    end
  end

  def exprs()
    print 'EXPRS - '
    if (@cs == 'minus' or @cs == 'plus')
      addop
      faddop
    else
      error('Expected a plus or a minus')
    end
  end

  def faddop()
    print 'FADDOP - '
    if (@cs == 'leftparen' or @cs == 'identifier' or @cs == 'integer')
      term
      fterm1
    else
      error("Expected something")
    end
  end

  def fterm1()
    print 'FTERM1 - '
    if (@cs == 'minus' or @cs == 'plus')
      exprs
    elsif(@cs == 'equal' or @cs == 'lteq')
      #do nothing
    else
      #donothing
    end
  end

  def term()
    print 'TERM - '
    if (@cs == 'leftparen' or @cs == 'identifier' or @cs == 'integer')
      factor
      ffactor
    else
      error("Expected a leftparen, identifier or integer")
    end
  end

  def ffactor()
    print 'FFACTOR - '
    if (@cs == 'multiply')
      terms
    else
      #do nothing
    end
  end

  def terms()
    print 'TERMS - '
    if (@cs == 'multiply')
      match('multiply')
      fmultiply
    else
      #do nothing
    end
  end

  def fmultiply()
    print 'FMULTIPLY - '
    if (@cs == 'leftparen' or @cs == 'identifier' or @cs == 'integer')
      factor
      ffactor1
    else
      error('Expected something')
    end
  end

  def ffactor1()
    print 'FFACTOR1 - '
    if (@cs == 'multiply')
      terms
    else
      #do nothing
    end
  end

  def factor()
    print 'FACTOR - '
    if (@cs == 'leftparen')
      match('leftparen')
      expr
      match('rightparen')
    elsif (@cs == 'identifier')
      match('identifier')
    elsif (@cs == 'integer')
      match('integer')
    else
      error('expected something')
    end
  end

  def lexpr()
    print 'LEXPR - '
    if (@cs == 'leftparen' or @cs == 'identifier' or @cs == 'integer')
      lterm
      flterm
    elsif (@cs == 'false' or @cs == 'true' or @cs == 'not')
      lterm
      flterm
    else
      error("Expected lexpr")
    end
  end

  def flterm()
    print 'FLTERM - '
    if (@cs == 'and')
      lexprs
    elsif (@cs == 'leftparen')
      #do nothing
    else
      #do nothing
    end
  end

  def lexprs()
    print 'LEXPRS - '
    if (@cs == 'and')
      match('and')
      fand
    else
      error ('Expected an "and"')
    end
  end

  def fand()
    print 'FAND - '
    if (@cs == 'leftparen' or @cs == 'identifier' or @cs == 'integer')
      lterm
      flterm1
    elsif (@cs == 'false' or @cs == 'true' or @cs == 'not')
      lterm
      flterm1
    else
      error('Expected a different symbol')
    end
  end

  def flterm1()
    print 'FLTERM1 - '
    if (@cs == 'and')
      lexprs
    elsif (@cs == 'rightparen')
      #do nothing
    else
      #do nothing
    end
  end

  def lterm()
    print 'LTERM - '
    if (@cs == 'false' or @cs == 'true')
      lfactor
    elsif (@cs == 'not')
      match('not')
      lfactor
    elsif (@cs == 'leftparen' or @cs == 'identifier' or @cs == 'integer')
      lfactor
    else
      error('Expected something for "LTERM"')
    end
  end

  def lfactor()
    print 'LFACTOR - '
    if (@cs == 'true')
      match('true')
    elsif (@cs == 'false')
      match('false')
    elsif (@cs == 'leftparen' or @cs == 'identifier' or @cs == 'integer')
      expr
      relop
      expr
    else
      error('expected something for LFACTOR')
    end
  end

  def relop()
    print 'RELOP - '
    if (@cs == 'equal')
      match('equal')
    elsif (@cs == 'lteq')
      match('lteq')
    else
      error('Expected a relationship operator')
    end
  end

  def addop()
    print 'ADDOP - '
    if (@cs == 'minus')
      match('minus')
    elsif (@cs == 'plus')
      match('plus')
    else
      error('Expected an +/- operator')
    end
  end

end


lexer = Lexer.new("test.while")
lexer.print_tokens
parser = Parser.new(lexer)

