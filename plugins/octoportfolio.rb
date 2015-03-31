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

module Octoportfolio

  def register_collection(collection, options = {})
    portfolio_title = collection.to_url

    # config uses whitespace-sensitive syntax
    portfolio_key = "#{portfolio_title}:".indent(2)
    output_key = "output: true".indent(4)
    permalink_key = "permalink: /#{portfolio_title}/:title/".indent(4)

    data = []
    data << portfolio_key
    data << output_key
    data << permalink_key
    data = data.join("\n")

    puts "Registering #{portfolio_title} collection in _config.yml..."
    update_collection_registry("_config.yml", data: data, title: portfolio_key)
    puts "done."
  end

  def update_collection_registry(file, record = {})
    orig_file = file
    new_file = "#{orig_file}.new"
    title, data = record[:title], record[:data]
    @registry_found = false
    @record_found = false

    # Read line from original file and write into new file
    File.open(new_file, 'w') do |f|
      File.foreach(orig_file) do |li|
        if @registry_found and !@record_found
          unless li.start_with? ''.indent(2)
            f.puts data
            @record_found = true
          end
        end

        @registry_found = true if li.start_with? "collections:"
        @record_found = true if li.start_with? title

        f.puts li
      end
    end

    File.rename(orig_file, "#{orig_file}.old")
    File.rename(new_file, orig_file)
    File.delete("#{orig_file}.old")

    unless @registry_found
      collection_registry_error(orig_file, data)
    end
  end

  def collection_registry_error(file, record)
    msg = []
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
