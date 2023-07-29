require "json"
require_relative "fileio"

class SyntaxDefinition
  attr_accessor :ext
  attr_accessor :token_defs
  attr_accessor :keyword_defs

  def initialize(name, token_defs, keyword_defs)
    @name = name
    @token_defs = token_defs.keys.map { |k|
      { type: k, regexp: Regexp.new(token_defs[k]) }
    }
    @keyword_defs = keyword_defs
  end
end

Token = Struct.new(:image, :type)

def load_syntax_def(filename)
  syntax_file = load_file(filename)

  if syntax_file == nil then return nil end

  data = JSON.parse(syntax_file)
  return SyntaxDefinition.new(data["ext"], data["tokens"], data["keywords"])
end

def tokenize(str, syntax_def)
  # skip tokenizing if no syntax def
  if syntax_def == nil
    return [Token.new(str, "none")]
  end

  token_defs = syntax_def.token_defs
  keyword_defs = syntax_def.keyword_defs
  toks = []

  offset = 0
  while offset < str.length
    first_match = { type: "none", index: -1, text: "" }

    # find next matching token
    token_defs.each { |d|
      m = d[:regexp].match(str, offset)
      # no match, continue
      if m == nil then next end

      # if this is a better match, update
      match_index = m.offset(0)[0]
      if match_index < first_match[:index] || first_match[:index] == -1
        first_match = { type: d[:type], index: match_index, text: m[0] }

        # stop if the match is at the very beginning
        if match_index == offset then break end
      end
    }

    if first_match[:index] > 0
      toks.push(Token.new(str[offset..first_match[:index]-1], "none"))
    end

    if first_match[:index] != -1
      toks.push(Token.new(
        first_match[:text],
        unless keyword_defs.include?(first_match[:text])
          first_match[:type]
        else
          "keyword"
        end
      ))
      offset = first_match[:index] + first_match[:text].length
    end

    # if no match was found, consume rest of string as "none"
    if first_match[:type].eql?("none")
      toks.push(Token.new(str[offset..], "none" ))
      offset = str.length
    end
  end

  return toks
end