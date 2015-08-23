require 'stringex'
require './plugins/cli_menu_helpers'

module Jekyll
  class Document

    # Create a Liquid-understandable version of this Document instance.
    # Returns a Hash representing Document's data.
    def to_liquid
      if data.is_a? Hash
        Utils.deep_merge_hashes data, {
          "output"        => output,
          "basename" => basename,
          "basename_without_ext" => basename_without_ext,
          "content"       => content,
          "relative_path" => relative_path,
          "path"          => relative_path,
          "url"           => url,
          "collection"    => collection.label
        }
      else
        data
      end
    end

  end
end

module Showcase
  CONFIG = "_config.yml"
  REGISTRY = "source/_data/collections.yml"

  def get_portfolios(source_dir)
    portfolios = []
    collections = false
    source_folders = Dir.entries(source_dir)
    source_folders.select! { |file| file.start_with? "_" }

    File.foreach(REGISTRY) do |li|
      collections = true if li.strip == "collections:"
      if collections && li.start_with?('  ') && li.strip.end_with?(':')
        portfolios << li.strip.chop
      end
    end

    portfolios.map! { |title| "_#{title}"}
    portfolios.select! { |folder| source_folders.include? folder }

    portfolios
  end

  def register_portfolio(name)
    name = name.to_url
    entry = ""

    # config files have whitespace-sensitive syntax
    portfolio = "#{name}:".indent(2)
    output = "output: true".indent(4)
    permalink = "permalink: /#{name}/:title/".indent(4)

    entry << "#{portfolio}\n#{output}\n#{permalink}"

    puts "Registering \"#{name}\" portfolio in #{CONFIG}..."
    update_collection_registry(CONFIG, entry: entry, index_key: portfolio)

    puts "Registering \"#{name}\" portfolio in #{REGISTRY}..."
    update_collection_registry(REGISTRY, entry: portfolio, index_key: portfolio)

    puts "done."
  end

  def update_collection_registry(file, record = {})
    orig_file = file
    new_file = "#{orig_file}.new"
    index_key, entry = record[:index_key], record[:entry]
    registry_found = false
    record_found = false

    File.open(new_file, 'w') do |f|
      File.foreach(orig_file) do |li|
        if registry_found and !record_found
          unless li.start_with? ''.indent(2)
            f.puts entry
            record_found = true
          end
        end

        registry_found = true if li.start_with? "collections:"
        record_found = true if li.start_with? index_key

        f.puts li
      end
    end

    File.rename(orig_file, "#{orig_file}.old")
    File.rename(new_file, orig_file)
    File.delete("#{orig_file}.old")

    unless registry_found
      collection_registry_error(orig_file, entry)
    end
  end

  def collection_registry_error(file, record)
    msg = []
    separator = "# ------------"

    msg << "CollectionsRegistryError: \'collections:\' registry key not found in #{file}"
    msg << "Add \'collections:\' to #{file} and run rake new_portfolio again"
    msg << "or copy and paste below record into #{file}"
    msg << separator
    msg << "collections:"
    msg << record
    msg << separator
    raise(msg.join("\n"))
  end

end

# for explicit formatting of whitespace-sensitive syntax
class String
  def indent(size=2, style=' ')
    "#{style * size}#{self}"
  end
end
