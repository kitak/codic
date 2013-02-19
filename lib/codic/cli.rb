require 'prompt'

module Codic
  class CLI
    extend Prompt::DSL

    command "suggest :word" do |word|
      Codic.display(Codic.suggest(word, Codic.suggest_dic(word)))
    end

    command "search :word" do |word|
      Codic.display(Codic.search(word))
    end

    command ":word" do |word|
      Codic.search_or_suggest(word.chomp)
    end

    class << self
      def start
        Prompt::Console.start
      end
    end
  end
end
