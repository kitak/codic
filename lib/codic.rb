# coding: utf-8
require "codic/version"
require "uri"
require "open-uri"
require "nokogiri"

module Codic
  URL_ROOT = "http://codic.jp"
  class << self
    def suggest(word)
    end

    def search(word)
      @doc = Nokogiri::HTML(open(URI.encode("#{Codic::URL_ROOT}/search?q=#{word}")))
      raise "Not Found" unless found?

      case entry_type 
      when "english"
        analyse_english
      when "naming"
        analyse_naming
      end
    end

    private
    def found?
      @doc.css('.not-found').empty?
    end

    def entry_type
      @doc.at('.entry')['class'].split(' ')[1]
    end

    def analyse_english
      @doc.at('#grammar .flections').content
      @doc.css('#translations .translation').map do |li|
        {
          no: li.at('.no').content[0..-2].to_i,
          class_ja: li.at('.word-class')['title'],
          class_en: li.at('.word-class')['class'].split(' ')[-1],
          translated: li.at('.translated').content
        }
      end
    end

    def analyse_naming
      @doc.css('#translations .translation').map do |article|
        word = article.at('.translated').content
        {
          translated: word,
          class_ja: article.at('.word-class').content,
          detail_url: "#{Codic::URL_ROOT}/entries/#{word}" 
        }
      end
    end
  end
end

if __FILE__ == $0
  puts Codic.search("access")
  puts Codic.search("検証する")
end
