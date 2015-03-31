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
  msg = options[:message] || ""
  verbose = options[:verbose] || false
  selections = []
  invalid = []

  # convert array to indexed hash for fast parsing of large option set
  list = list.map.with_index { |elem, i| [i+1, elem] }.to_h
  menu_items = list.map { |pair| pair.join(" ) ") }.join("\n")
  menu = "#{msg}" || ""
  menu << "\n#{menu_items}"
  menu << "\nEnter menu number(s) of file(s) to update:"

  # sanitize response of multiple selections separated by space or comma
  response = ask(menu).split(/[,\s]/).reject(&:empty?)

  response.each do |selection|
    selection = selection.to_i
    if list.has_key? selection
      selections <<  list[selection]
    else
      invalid << selection
    end
  end

  if verbose
    invalid.each do |selection|
      puts "No post found for [ #{selection} ]. Skipping..."
    end
  end

  selections
end

