# coding: utf-8
require "codic/version"
require "uri"
require "open-uri"
require "nokogiri"
require "json"


module Codic
  URL_ROOT = "http://codic.jp"

  class CodicError < StandardError; end

  module ContentCushion 
    def content 
      ""
    end
  end
  class ::NilClass 
    include Codic::ContentCushion
  end

  class << self
    def suggest(word, dic)
      res =  JSON.parse(open(URI.encode("#{Codic::URL_ROOT}/suggest?q=#{word}&dic=#{dic}"),
                        "Accept" => "application/json, text/javascript, */*; q=0.01",
                        "X-Requested-With" => "XMLHttpRequest").read)
      res["titles"].map! { |t| t.gsub(/\<\/?mark\>/, '') }
      suggests = res["titles"].zip(res["descriptions"], res["urls"]).map do |t, d, u|
        {
          title: t,
          description: d,
          url: u
        }
      end

      {
        type: "suggest",
        suggests: suggests
      }
    end

    def search(word)
      raise ArgumentError, "word is empty" if word.gsub(/\s/, "") == ""
      @doc = Nokogiri::HTML(open(URI.encode("#{Codic::URL_ROOT}/search?q=#{word}")))
      raise CodicError, "Not Found" unless found?

      case entry_type 
      when "english"
        analyse_english
      when "naming"
        analyse_naming
      end
    end

    def display(result)
      case result[:type]
      when "english"
        unless result[:flections] == ""
          puts result[:flections] 
          puts
        end
        result[:words].each do |w|
          puts "#{w[:no]}. #{w[:translated]} [#{w[:class_ja]}]" 
        end
      when "naming"
        result[:words].each do |w|
          puts "#{w[:translated]} [#{w[:class_ja]}]"
          unless w[:description] == ""
            puts "  #{w[:description]}" 
            puts 
          end
        end
      when "suggest"
        result[:suggests].each do |s|
          puts "#{s[:title]} #{s[:description]}"
        end
      else
        raise ArgumentError, "Invalid Type"
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
      flections = @doc.at('#grammar .flections').content
      words = @doc.css('#translations .translation').map do |li|
        {
          no: li.at('.no').content[0..-2].to_i,
          class_ja: li.at('.word-class')['title'],
          class_en: li.at('.word-class')['class'].split(' ')[-1],
          translated: li.at('.translated').content
        }
      end

      {
        type: "english",
        flections: flections,
        words: words
      }
    end

    def analyse_naming
      words = @doc.css('#translations .translation').map do |article|
        w = article.at('.translated').content
        {
          translated: w,
          class_ja: article.at('.word-class').content,
          description: article.at('.description').content,
          url: "#{Codic::URL_ROOT}/entries/#{w}" 
        }
      end

      {
        type: "naming",
        words: words
      }
    end
  end
end

if __FILE__ == $0
  puts Codic.search("access")
  puts Codic.search("検証する")
  puts Codic.suggest("検証す", "naming")
  puts Codic.suggest("red", "english")
end
