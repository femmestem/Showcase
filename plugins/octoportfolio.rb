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
