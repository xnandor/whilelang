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



class Taxer
  @error = false
  @lexer

  def initialize(lexer)
    @error = false
    @lexer = lexer
  end

  def analyze()
    descend(@lexer)
  end

  def descend(lexer)
    if (token = lexer.get_token)
      if (!token_good(token, lexer))
        @error = true
      end
      descend(lexer)
    else
      if (@error)
        puts "Syntax Error"
      else
        puts "Syntax formed correctly!!!"
      end
    end
  end

  def token_good(token, lexer)
    error = false
    if (token == "if")
      error = error || lexer.get_token != "("
    end

    return true #!error
  end

  def skip?

  end


end

lexer = Lexer.new("test.while")
lexer.print_tokens
taxer = Taxer.new(lexer)
taxer.analyze


