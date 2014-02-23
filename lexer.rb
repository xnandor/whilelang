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
  @current_symbol
  @symbols

  def initialize(lexer)
    @lexer = lexer
    @symbols = {
      "plus"       => 1,
      "minus"      => 2,
      "lteq"       => 3,
      "equal"      => 4,
      "multiply"   => 5,
      "divide"     => 6,
      "true"       => 7,
      "false"      => 8,
      "and"        => 9,
      "not"        => 10,
      "if"         => 11,
      "then"       => 12,
      "else"       => 13,
      "while"      => 14,
      "do"         => 15,
      "skip"       => 16,
      "identifier" => 17,
      "leftparen"  => 18,
      "rightparen" => 19,
      "integer"    => 20,
      ";"          => 21,
      "assign"     => 22,
      "EOF"        => 23
    }
    get_symbol()
    program
  end

  def get_symbol()
    token = @lexer.get_token
    puts token
    case token
    when /^\+$/
      @current_symbol = @symbols["plus"]
    when /^\-$/
      @current_symbol = @symbols["minus"]
    when /^<=$/
      @current_symbol = @symbols["lteq"]
    when /^=$/
      @current_symbol = @symbols["equal"]
    when /^\*$/
      @current_symbol = @symbols["multiply"]
    when /^\/$/
      @current_symbol = @symbols["divide"]
    when /^true$/
      @current_symbol = @symbols["true"]
    when /^false$/
      @current_symbol = @symbols["false"]
    when /^and$/
      @current_symbol = @symbols["and"]
    when /^not$/
      @current_symbol = @symbols["not"]
    when /^if$/
      @current_symbol = @symbols["if"]
    when /^then$/
      @current_symbol = @symbols["then"]
    when /^else$/
      @current_symbol = @symbols["else"]
    when /^while$/
      @current_symbol = @symbols["while"]
    when /^do$/
      @current_symbol = @symbols["do"]
    when /^skip$/
      @current_symbol = @symbols["skip"]
    when /^[a-zA-Z][\w\d]*$/
      @current_symbol = @symbols["identifier"]
    when /^\($/
      @current_symbol = @symbols["leftparen"]
    when /^\)$/
      @current_symbol = @symbols["rightparen"]
    when /^\d+$/
      @current_symbol = @symbols["integer"]
    when /^;$/
      @current_symbol = @symbols[";"]
    when /^:=$/
      @current_symbol = @symbols["assign"]
    when /^EOF$/
      @current_symbol = @symbols["EOF"]
    else

    end

  end

  def accept(symbol)
    if (symbol == @current_symbol)
      get_symbol()
      return true
    end
    return false
  end

  def expect(symbol)
    if (accept symbol)
      return true
    end
    error("Error: unexpected symbol: #{@current_symbol}")
    return false
  end

  def error(message)
    puts message
  end

  def expr()
    term()
    
  end

  def stmt()
    if (accept(@symbols["skip"]))

    elsif (accept(@symbols["identifier"]))
      expect(@symbols["assign"])
      expr()
    elsif (accept(@symbols["if"]))
      expect(@symbols["leftparen"])
      lexpr()
      expect(@symbols["rightparen"])
      expect(@symbols["then"])
      expect(@symbols["leftparen"])
      stmts()
      expect(@symbols["rightparen"])
      expect(@symbols["else"])
      expect(@symbols["leftparen"])
      stmts()
      expect(@symbols["rightparen"])
    elsif (accept(@symbols["while"]))
      expect(@symbols["leftparen"])
      lexpr()
      expect(@symbols["rightparen"])
      expect(@symbols["do"])
      expect(@symbols["leftparen"])
      stmts()
      expect(@symbols["rightparen"])
    else
      error("Parse Error: Expected a statement")
    end
  end

  def stmts()
    stmt()
    while (@current_symbol == @symbols[";"])
      get_symbol()
      stmts()
    end
  end

  def program()
    stmts()
    expect(@symbols["EOF"])
  end

end

lexer = Lexer.new("test.while")
lexer.print_tokens
parser = Parser.new(lexer)



