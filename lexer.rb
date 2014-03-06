#!/usr/bin/ruby

class Lexer
  @variables = {}
  @tokens = []
  @point = 0
  @original
  
  def initialize(filename)
    if (filename == nil)
      puts " "
      puts "USAGE ERROR: PLEASE GIVE FILE AS ARGUMENT:"
      puts "\t lexter.rb <WHILE FILE>"
      puts " "
      abort()
    end
    @variables = {}
    @tokens = []
    @point = 0
    file = File.open(filename)
    parse(file)
  end

  def parse(file)
    text = file.read
    @original = String.new(text) # used later in parser feedback
    #remove comments
    while (text =~ /\/\/.*$/)
      text.slice!(/\/\/.*$/)
    end
    #token rules
    regtokens = /[a-zA-Z][\w\d]*|:=|\+|\-|\*|\(|\)|<=|=|\d+|;|true|false|and|not|skip|if|then|else|while|do/
    #find invalid tokens
    invalid = String.new(text)
    while (invalid =~ regtokens)
      invalid.slice!(regtokens)
    end
    while (invalid =~ /\s+/)
      invalid.slice!(/\s+/)
    end
    #throw error if invalid symbols
    if (invalid != '')
      puts " "
      puts "TOKEN ERROR: There was one or more invalid symbols:  "
      puts "\t" << invalid
      puts " "
      abort()
    end
    #extract valid tokens
    @tokens = []
    lines = @original.split(/^/)
    linenum = 0
    charnum = 1
    puts "________TOKEN__________LINE_NUMBER___CHARACTER_NUMBER____"
    text.scan(regtokens){
      |token|
      while (lines[linenum].index(token) == nil)
        linenum = linenum + 1
      end
      charnum = lines[linenum].index(token)
      sliced = lines[linenum].slice!(token)
      lines[linenum] = lines[linenum].prepend(" "*sliced.length)
      l = linenum+1
      c = charnum
      puts "\t #{token}\t\t\t(#{l},#{charnum})"
      @tokens.push([token, l, c]);
    }
    @tokens.insert(-1,["EOF",0,0])
  end

  def get_code_lines()
    return @original.split(/^/)
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
  @cl #Current Line
  @cc #Current Character
  @symbols

  def initialize(lexer)
    @lexer = lexer
    get_symbol()
    program
    programend
  end

  def get_symbol()
    token = @lexer.get_token
    @cl = token[1]
    @cc = token[2]
    case token[0]
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
      puts ''
      puts "      __..--~~==##` NO ERRORS '##==~~--..__"
      puts ''
      abort()
    end
    if (accept? symbol)
      return true
    end
    error()
    return false
  end

  def error()
    puts " "
    puts "PARSE ERROR: UNEXPECTED SYMBOL AT LOCATION: l.#{@cl} c.#{@cc}"
    line = @lexer.get_code_lines[@cl-1]
    puts "\t" << line
    arrow = "\t" << " "*@cc << "^"
    puts  arrow
    puts " "
    abort()
  end

  def program()
    if (@cs == 'identifier' or @cs == 'while' or @cs == 'if' or @cs == 'skip')
      stmts
    else
      error()
    end
  end

  def programend()
    if (@cs == 'EOF')
      match("EOF")
    else
      error()
    end
  end

  def stmts()
    if (@cs == 'identifier' or @cs == 'while' or @cs == 'if' or @cs == 'skip')
      stmt
      fstmt
    else
      error()
    end
  end

  def fstmt()
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
      error()
    end
  end

  def expr()
    if (@cs == 'leftparen' or @cs == 'identifier' or @cs == 'integer')
      term
      fterm
    else
      error()
    end
  end

  def fterm()
    if (@cs == 'minus' or @cs == 'plus')
      exprs
    elsif (@cs == 'equal' or @cs == 'lteq' or @cs == 'and' or @cs == 'rightparen' or @cs == 'break')
      #do nothing
    else
      #do nothing
    end
  end

  def exprs()
    if (@cs == 'minus' or @cs == 'plus')
      addop
      faddop
    else
      error()
    end
  end

  def faddop()
    if (@cs == 'leftparen' or @cs == 'identifier' or @cs == 'integer')
      term
      fterm1
    else
      error()
    end
  end

  def fterm1()
    if (@cs == 'minus' or @cs == 'plus')
      exprs
    elsif(@cs == 'equal' or @cs == 'lteq')
      #do nothing
    else
      #donothing
    end
  end

  def term()
    if (@cs == 'leftparen' or @cs == 'identifier' or @cs == 'integer')
      factor
      ffactor
    else
      error()
    end
  end

  def ffactor()
    if (@cs == 'multiply')
      terms
    else
      #do nothing
    end
  end

  def terms()
    if (@cs == 'multiply')
      match('multiply')
      fmultiply
    else
      #do nothing
    end
  end

  def fmultiply()
    if (@cs == 'leftparen' or @cs == 'identifier' or @cs == 'integer')
      factor
      ffactor1
    else
      error()
    end
  end

  def ffactor1()
    if (@cs == 'multiply')
      terms
    else
      #do nothing
    end
  end

  def factor()
    if (@cs == 'leftparen')
      match('leftparen')
      expr
      match('rightparen')
    elsif (@cs == 'identifier')
      match('identifier')
    elsif (@cs == 'integer')
      match('integer')
    else
      error()
    end
  end

  def lexpr()
    if (@cs == 'leftparen' or @cs == 'identifier' or @cs == 'integer')
      lterm
      flterm
    elsif (@cs == 'false' or @cs == 'true' or @cs == 'not')
      lterm
      flterm
    else
      error()
    end
  end

  def flterm()
    if (@cs == 'and')
      lexprs
    elsif (@cs == 'leftparen')
      #do nothing
    else
      #do nothing
    end
  end

  def lexprs()
    if (@cs == 'and')
      match('and')
      fand
    else
      error ()
    end
  end

  def fand()
    if (@cs == 'leftparen' or @cs == 'identifier' or @cs == 'integer')
      lterm
      flterm1
    elsif (@cs == 'false' or @cs == 'true' or @cs == 'not')
      lterm
      flterm1
    else
      error()
    end
  end

  def flterm1()
    if (@cs == 'and')
      lexprs
    elsif (@cs == 'rightparen')
      #do nothing
    else
      #do nothing
    end
  end

  def lterm()
    if (@cs == 'false' or @cs == 'true')
      lfactor
    elsif (@cs == 'not')
      match('not')
      lfactor
    elsif (@cs == 'leftparen' or @cs == 'identifier' or @cs == 'integer')
      lfactor
    else
      error()
    end
  end

  def lfactor()
    if (@cs == 'true')
      match('true')
    elsif (@cs == 'false')
      match('false')
    elsif (@cs == 'leftparen' or @cs == 'identifier' or @cs == 'integer')
      expr
      relop
      expr
    else
      error()
    end
  end

  def relop()
    if (@cs == 'equal')
      match('equal')
    elsif (@cs == 'lteq')
      match('lteq')
    else
      error()
    end
  end

  def addop()
    if (@cs == 'minus')
      match('minus')
    elsif (@cs == 'plus')
      match('plus')
    else
      error()
    end
  end

end

lexer = Lexer.new(ARGV[0])
parser = Parser.new(lexer)

