# ================ #
# Cli Menu Helpers #
# ================ #

def ok_failed(condition)
  if condition
    puts "OK"
  else
    puts "FAILED"
  end
end

def get_stdin(message)
  print message
  STDIN.gets.chomp
end

def ask(message, valid_options = false)
  if valid_options
    answer = get_stdin("#{message} #{valid_options.to_s.gsub(/"/, '').gsub(/, /,'/')} ") until valid_options.include?(answer)
  else
    answer = get_stdin(message)
  end
  answer
end

def overwrite_confirmed?(file)
  return true unless File.exist? file
  ask("\n\"#{file}\" already exists.\nDo you want to overwrite?", ['y', 'n']) == 'y'
end


def set_title(args = {})
  title = args[:title]
  default = args[:default] || "untitled"

  unless title
    title = get_stdin("Enter a title: ")
    title = default if title.empty?
  end
  title.downcase
end

def filter_files(args = {})
  keyword = args[:filename].downcase
  list = args[:list]

  # Decrease specificity if no matches found in previous search
  matches = list.select { |file| keyword == file.downcase }
  matches = list.select { |file| file.downcase.start_with? keyword } if matches.empty?
  matches = list.select { |file| file.downcase.include? keyword } if matches.empty?

  matches
end


def get_menu_selection(list, options = {})
  pre_msg = options[:pre_msg] || ""
  post_msg = options[:post_msg] || "Enter menu number(s) of file(s) to update: "
  verbose = options[:verbose] || false
  allow_multiple = options[:allow_multiple] || false
  selections = []
  valid = []

  # convert array to indexed hash for fast parsing of large option set
  list = list.map.with_index { |elem, i| [i+1, elem] }.to_h
  menu_items = list.map { |pair| pair.join(" ) ") }.join("\n")
  menu = "#{pre_msg}\n#{menu_items}\n#{post_msg}"

  # sanitize response with multiple selections separated by space or comma
  response = ask(menu).split(/[,\s]/).reject(&:empty?)

  if allow_multiple
    selections = response
  else
    selections << response.first
  end

  selections.each do |selection|
    selection = selection.to_i
    if list.has_key? selection
      valid <<  list[selection]
    else
      puts "No matches for [ #{selection} ]. Skipping..." if verbose
    end
  end

  valid
end

