require './plugins/cli_menu_helpers'

module Publisher

  def update_front_matter(args = {})
    front_matter_keys = args[:front_matter]
    raise " Expecting :front_matter => { key1: 'a', key2: 'b' }" unless front_matter_keys and front_matter_keys.is_a? Hash
    file = args[:file]
    default_front_matter = "---\n---"

    contents = IO.read(file)
    front_matter_re = /^-{3}.+^-{3}$/m
    front_matter = contents.scan(front_matter_re).first

    if front_matter.nil?
      front_matter = default_front_matter
      contents = "#{front_matter}\n#{contents}"
    end

    front_matter_keys.each do |key, value|
      new_key = "\n#{key}: #{value}" unless "#{value}".empty?
      new_key ||= ""
      if front_matter.include? "#{key}"
        front_matter.gsub!(/^#{key}.*\s/, new_key)
      else
        front_matter.sub!(/^-{3}/, "---#{new_key}") unless new_key.empty?
      end
    end

    File.open(file, 'w') do |f|
      f.puts contents.sub(front_matter_re, front_matter)
    end
  end

  def publish(title, config = {})
    count = 0
    yml = config[:front_matter]
    source, dest = config[:source], config[:destination]

    new_title = "#{datestamp}-#{title}"
    old_file, new_file = "#{source}/#{title}", "#{dest}/#{new_title}"

    if !File.exist? new_file or overwrite_confirmed? new_file
      puts "\nPublishing #{title}..."
      update_front_matter(file: old_file, front_matter: yml)
      mv old_file, new_file
      count += 1
    end
    count
  end

  def unpublish(title, config = {})
    count = 0
    yml = config[:front_matter]
    source, dest = config[:source], config[:destination]

    new_title = title.sub(/\d{4}-\d{2}-\d{2}-/, '')
    old_file, new_file = "#{source}/#{title}", "#{dest}/#{new_title}"

    if !File.exist? new_file or overwrite_confirmed? new_file
      puts "\nReverting #{title} to draft..."
      update_front_matter(file: old_file, front_matter: yml)
      mv old_file, new_file
      count += 1
    end
    count
  end

end
