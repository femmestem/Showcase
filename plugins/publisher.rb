require './plugins/cli_menu_helpers'

module Publisher

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

  def get_front_matter(file)
    marker_count = 0
    front_matter = []

    File.foreach (file) do |li|
      marker_count += 1 if li.chomp == "---"

      if marker_count > 0
        front_matter << li unless li.chomp == "---"
      end

      return nil if marker_count == 0
      return front_matter.join if marker_count >= 2
    end
    nil
  end

  def update_front_matter(args = {})
    orig_file = args[:file]
    new_file = "#{orig_file}.new"

    fm_options = args[:front_matter] || {}
    orig_fm = get_front_matter(orig_file)
    new_fm = orig_fm || ""

    raise "Invalid front matter format. Expecting :front_matter => { option1: 'a', option2: 'b' }" unless fm_options and fm_options.is_a? Hash

      fm_options.each do |key, value|
        new_key = "#{key}: #{value}\n" unless "#{value}".empty?
        new_key ||= ""
        if orig_fm
          if new_fm.include? "#{key}"
            new_fm.gsub!(/^#{key}.*\s/, new_key)
          else
            new_fm.sub!('', new_key) unless new_key.empty?
          end
        else
          new_fm += new_key unless new_key.empty?
        end
      end

    marker_count = 0
    File.open(new_file, 'w') do |f|
      f.puts "---"
      f.write new_fm
      f.puts "---"
      File.foreach(orig_file) do |li|
        if orig_fm.nil?
          f.puts li
        else
          f.puts li unless marker_count < 2
          marker_count += 1 if li.chomp == "---"
        end
      end
    end

    File.rename(orig_file, "#{orig_file}.old")
    File.rename(new_file, orig_file)
    File.delete("#{orig_file}.old")
  end

end
