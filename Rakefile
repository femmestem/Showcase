require "rubygems"
require "bundler/setup"
require "stringex"
require "./plugins/titlecase"
require "./plugins/cli_menu_helpers"
require "./plugins/publisher"
require "./plugins/showcase"

## -- Rsync Deploy config -- ##
# Be sure your public key is listed in your server's ~/.ssh/authorized_keys file
ssh_user       = "user@domain.com"
ssh_port       = "22"
document_root  = "~/website.com/"
rsync_delete   = false
rsync_args     = ""  # Any extra arguments to pass to rsync
deploy_default = "rsync"

# This will be configured for you when you run config_deploy
deploy_branch  = "gh-pages"

## -- Misc Configs -- ##
def datetimestamp
  Time.now.strftime('%Y-%m-%d %H:%M:%S %z')
end

def datestamp
 Time.now.strftime('%Y-%m-%d')
end

public_dir      = "public"    # compiled site directory
source_dir      = "source"    # source file directory
blog_index_dir  = "source/blog"    # directory for your blog's index page (if you put your index in source/blog/index.html, set this to 'source/blog')
deploy_dir      = "_deploy"   # deploy directory (for Github pages deployment)
stash_dir       = "_stash"    # directory to stash posts for speedy generation
posts_dir       = "_posts"    # directory for blog files
drafts_dir      = "_drafts"    # directory for unpublished blog posts
portfolio_reg   = "_data/collections.yml"   # registry of Jekyll Collection keys for portfolios
themes_dir      = ".themes"   # directory for blog files
new_post_ext    = "markdown"  # default new post file extension when using the new_post task
new_page_ext    = "markdown"  # default new page file extension when using the new_page task
new_project_ext = "markdown"  # default new project file extension when using the new_project task
server_port     = "4000"      # port for preview server eg. localhost:4000

if (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  puts '## Set the codepage to 65001 for Windows machines'
  `chcp 65001`
end

desc "Initial setup for Showcase: copies the default theme into the path of Jekyll's generator. Rake install defaults to rake install[classic] to install a different theme run rake install[some_theme_name]"
task :install, :theme do |t, args|
  if File.directory?(source_dir) || File.directory?("sass")
    abort("rake aborted!") unless ask("A theme is already installed, proceeding will overwrite existing files. Are you sure?", ['y', 'n']) == 'y'
  end
  # copy theme into working Jekyll directories
  theme = args.theme || 'classic'
  puts "## Copying #{theme} theme into ./#{source_dir} and ./sass"
  mkdir_p source_dir
  cp_r "#{themes_dir}/#{theme}/source/.", source_dir
  mkdir_p "sass"
  cp_r "#{themes_dir}/#{theme}/sass/.", "sass"
  mkdir_p "#{source_dir}/#{posts_dir}"
  mkdir_p public_dir
end

#######################
# Working with Jekyll #
#######################

desc "Generate jekyll site"
task :generate do
  verify_installation(source_dir)
  puts "## Generating Site with Jekyll"
  system "compass compile --css-dir #{source_dir}/stylesheets"
  system "jekyll build"
end

desc "Watch the site and regenerate when it changes"
task :watch do
  verify_installation(source_dir)
  puts "Starting to watch source with Jekyll and Compass."
  system "compass compile --css-dir #{source_dir}/stylesheets" unless File.exist?("#{source_dir}/stylesheets/screen.css")
  jekyllPid = Process.spawn({"OCTOPRESS_ENV"=>"preview"}, "jekyll build --watch")
  compassPid = Process.spawn("compass watch")

  trap("INT") {
    [jekyllPid, compassPid].each { |pid| Process.kill(9, pid) rescue Errno::ESRCH }
    exit 0
  }

  [jekyllPid, compassPid].each { |pid| Process.wait(pid) }
end

# usage: rake preview to see published posts or rake preview[drafts] to include drafts in preview
desc "Preview the site in a web browser (\'drafts\' optional)"
task :preview, :drafts do |t, args|
  verify_installation(source_dir)
  puts "Starting to watch source with Jekyll and Compass. Starting Rack on port #{server_port}"
  system "compass compile --css-dir #{source_dir}/stylesheets" unless File.exist?("#{source_dir}/stylesheets/screen.css")
  build_type = "jekyll build --watch"
  build_type << " --drafts" if args.drafts && args.drafts[/^draft/]
  jekyllPid = Process.spawn({"Showcase_ENV"=>"preview"}, "#{build_type}")
  compassPid = Process.spawn("compass watch")
  rackupPid = Process.spawn("rackup --port #{server_port}")

  trap("INT") {
    [jekyllPid, compassPid, rackupPid].each { |pid| Process.kill(9, pid) rescue Errno::ESRCH }
    exit 0
  }

  [jekyllPid, compassPid, rackupPid].each { |pid| Process.wait(pid) }
end

# usage rake new_post[my-new-post] or rake new_post['my new post'] or rake new_post (defaults to "new-post")
desc "Begin a new post in #{source_dir}/#{posts_dir}"
task :new_post, :title do |t, args|
  verify_installation(source_dir)

  title = set_title(title: args.title, default: "new post")
  file = "#{source_dir}/#{posts_dir}/#{datestamp}-#{title.to_url}.#{new_post_ext}"
  abort("rake aborted!") if File.exist? file unless overwrite_confirmed? file
  yml = {
    date: datetimestamp,
    layout: "post",
    title: "\"#{title.gsub(/&/,'&amp;').titlecase}\"",
    comments: "true",
    categories: ""
  }

  mkdir_p "#{source_dir}/#{posts_dir}"
  puts "Creating new post: #{file}"
  write_new_page(file, yml)
end

# usage rake new_page[my-new-page] or rake new_page[my-new-page.html] or rake new_page (defaults to "new-page.markdown")
desc "Create a new page in #{source_dir}/(filename)/index.#{new_page_ext}"
task :new_page, :filename do |t, args|
  verify_installation(source_dir)
  args.with_defaults(:filename => 'new page')
  filename = args.filename.downcase

  page_dir = dirname(filename, source_dir)
  basename, dot, ext = File.basename(filename).rpartition(".").reject(&:empty?)
  title, page = basename.titlecase, basename.to_url

  unless ext
    page_dir << "/#{page}"
    page = "index"
    ext = new_project_ext
  end

  page_path = "#{page_dir}/#{page}.#{ext}"
  dir_root = page_path.split('/')[1]

  # check for name conflict with compiled portfolio folders
  page_alias = "_#{dir_root}"
  if Dir.entries(source_dir).include? page_alias
    abort("rake aborted! \"#{source_dir}/#{dir_root}\" name conflict with \"#{source_dir}/#{page_alias}\" on site build")
  end

  abort("rake aborted!") if File.exist? page_path unless overwrite_confirmed? page_path

  yml = {
    layout: "page",
    title: "\"#{title}\"",
    date: "#{datetimestamp}",
    comments: "true",
    sharing: "true",
    footer: "true"
  }

  mkdir_p page_dir
  puts "Creating new page: #{page_path}"
  write_new_page(page_path, yml)
end

# usage rake new_portfolio[my-new-portfolio] or rake new_portfolio[my-new-portfolio.html] or rake new_portfolio (defaults to "new-portfolio.markdown")
desc "Create a new portfolio in #{source_dir}/_(title)"
task :new_portfolio, :title do |t, args|
  include Showcase
  verify_installation(source_dir)

  title = set_title(title: args.title, default: "new portfolio")
  portfolio = "#{source_dir}/_#{title.to_url}"

  portfolio_alias = "#{source_dir}/#{title.to_url}"
  abort("rake aborted! \"#{portfolio}\" conflicts with existing page \"#{portfolio_alias}\" when building site") if File.exist? portfolio_alias

  index = "#{portfolio}/index.#{new_page_ext}"
  abort("rake aborted!") if File.exist? index unless overwrite_confirmed? index

  yml = {
    layout: "portfolio_index",
    title: "\"#{title.titlecase}\"",
    projects: "[]",
    permalink: "/#{title.to_url}/index.html",
    comments: "false",
    sharing: "false",
    footer: "false",
    sidebar: "false"
  }

  puts "Creating new portfolio: #{portfolio}"
  mkdir_p portfolio
  puts "Creating portfolio index: #{index}"
  write_new_page(index, yml)
  register_portfolio title
end

desc "Create a new project in #{source_dir}/_portfolio/(filename)"
task :new_project, :filename do |t, args|
  include Showcase
  verify_installation(source_dir)
  args.with_defaults(:filename => 'new project')
  portfolio_list = get_portfolios(source_dir)
  portfolio = ""

  filename = args.filename.downcase
  basename, dot, ext = File.basename(filename).partition(".").reject(&:empty?)
  title, project = basename.titlecase, basename.to_url
  ext ||= new_project_ext

  portfolio = dirname(filename)
  if portfolio.empty?
    before_menu = "Portfolios in registry (#{portfolio_reg}):"
    after_menu = "In which portfolio does \"#{title}\" project belong? (enter number): "
    portfolio = get_menu_selection(portfolio_list, :pre_msg => before_menu, :post_msg => after_menu, :verbose => true).first
  else
    portfolio = "_#{portfolio}" unless portfolio.start_with? "_"
    abort("rake aborted! No such portfolio \"#{portfolio}\"") unless portfolio_list.include? portfolio
  end

  project_path = "#{source_dir}/#{portfolio}/#{project}.#{ext}"
  abort("rake aborted!") if File.exist? project_path unless overwrite_confirmed? project_path

  yml = {
  layout: "project",
  title: "\"#{title}\"",
  gallery_path: "../../#{project}",
  include_images: "[]",
  cover_image_path: "",
  site: "",
  github: "",
  bitbucket: ""
  }

  puts "Creating new project page \"#{project}.#{ext}\" in \"#{portfolio}/\""
  puts "> #{project_path}"
  write_new_page(project_path, yml)
  puts "Creating project image gallery at \"#{source_dir}/images/#{project}\""
  mkdir_p "#{source_dir}/images/#{project}"
end

# usage rake new_draft[my-unpublished-draft] or rake new_draft['my new unpublished draft'] or rake new_draft (defaults to "new-draft")
desc "Begin a new draft post in #{source_dir}/#{drafts_dir}"
task :new_draft, :title do |t, args|
  verify_installation(source_dir)

  title = set_title(title: args.title, default: "new draft")
  file = "#{source_dir}/#{drafts_dir}/#{title.to_url}.#{new_post_ext}"
  abort("rake aborted!") if File.exist? file unless overwrite_confirmed? file
  yml = {
    layout: "post",
    title: "\"#{title.gsub(/&/,'&amp;').titlecase}\"",
    comments: "true",
    categories: ""
  }

  mkdir_p "#{source_dir}/#{drafts_dir}"
  puts "Creating new draft: #{file}"
  write_new_page(file, yml)
end

desc "Publish posts from #{source_dir}/#{drafts_dir} to #{source_dir}/#{posts_dir}"
task :publish, :title do |t, args|
  include Publisher
  args.with_defaults(:title => '')
  @publish_count = 0
  config = {
    source: "#{source_dir}/#{drafts_dir}",
    destination: "#{source_dir}/#{posts_dir}",
    front_matter: {
      date: "#{datetimestamp}",
      published: nil
    }
  }

  # Sanitize filename
  title = args[:title].split(".").map { |x| x.to_url }.join(".").downcase
  drafts = Dir.entries("#{config[:source]}").reject! { |file| file.start_with? "." }

  matches = filter_files(filename: title, list: drafts)

  if matches.count == 1 and matches[0] == title
    @publish_count += publish(title, config)
  else
    menu_msg = ""
    menu_msg << "No posts found for \"#{title}\"" if matches.empty?
    menu_msg << "\nDrafts waiting to be published:"
    list = matches.empty? ? drafts : matches
    menu_response = get_menu_selection(list, :pre_msg => menu_msg, :verbose => true, :allow_multiple => true)
    menu_response.each do |selection|
      @publish_count += publish(selection, config)
    end
  end

  puts "\nDone. #{@publish_count} posts published."
end

desc "Revert post from #{source_dir}/#{posts_dir} to draft in #{source_dir}/#{drafts_dir}"
task :unpublish, :title do |t, args|
  include Publisher
  args.with_defaults(:title => '')
  @unpublish_count = 0
  config = {
    source: "#{source_dir}/#{posts_dir}",
    destination: "#{source_dir}/#{drafts_dir}",
    front_matter: {
      date: nil
    }
  }

  # Sanitize filename
  title = args[:title].split(".").map { |x| x.to_url }.join(".").downcase
  posts = Dir.entries("#{config[:source]}").reject! { |file|
    file.start_with? "." }

  matches = filter_files(filename: title, list: posts)

  if matches.count == 1 and matches[0] == title
    @unpublish_count += unpublish(title, config)
  else
    menu_msg = ""
    menu_msg << "No posts found for \"#{title}\"" if matches.empty?
    menu_msg << "\nPublished posts:"

    list = matches.empty? ? posts : matches
    menu_response = get_menu_selection(list, :pre_msg => menu_msg, :verbose => true, :allow_multiple => true)

    menu_response.each do |selection|
      @unpublish_count += unpublish(selection, config)
    end
  end

  puts "\nDone. #{@unpublish_count} posts reverted to draft."
end

# usage rake isolate[my-post]
desc "Move all other posts than the one currently being worked on to a temporary stash location (stash) so regenerating the site happens much more quickly."
task :isolate, :filename do |t, args|
  stash_dir = "#{source_dir}/#{stash_dir}"
  FileUtils.mkdir(stash_dir) unless File.exist?(stash_dir)
  Dir.glob("#{source_dir}/#{posts_dir}/*.*") do |post|
    FileUtils.mv post, stash_dir unless post.include?(args.filename)
  end
end

desc "Move all stashed posts back into the posts directory, ready for site generation."
task :integrate do
  FileUtils.mv Dir.glob("#{source_dir}/#{stash_dir}/*.*"), "#{source_dir}/#{posts_dir}/"
end

desc "Clean out caches: .pygments-cache, .gist-cache, .sass-cache"
task :clean do
  rm_rf [Dir.glob(".pygments-cache/**"), Dir.glob(".gist-cache/**"), Dir.glob(".sass-cache/**"), "source/stylesheets/screen.css"]
end

desc "Move sass to sass.old, install sass theme updates, replace sass/custom with sass.old/custom"
task :update_style, :theme do |t, args|
  theme = args.theme || 'classic'
  if File.directory?("sass.old")
    puts "Removed existing sass.old directory"
    rm_r "sass.old", :secure=>true
  end
  mv "sass", "sass.old"
  puts "## Moved styles into sass.old/"
  cp_r "#{themes_dir}/"+theme+"/sass/", "sass", :remove_destination=>true
  cp_r "sass.old/custom/.", "sass/custom/", :remove_destination=>true
  puts "## Updated Sass ##"
end

desc "Move source to source.old, install source theme updates, replace source/_includes/navigation.html with source.old's navigation"
task :update_source, :theme do |t, args|
  theme = args.theme || 'classic'
  if File.directory?("#{source_dir}.old")
    puts "## Removed existing #{source_dir}.old directory"
    rm_r "#{source_dir}.old", :secure=>true
  end
  mkdir "#{source_dir}.old"
  cp_r "#{source_dir}/.", "#{source_dir}.old"
  puts "## Copied #{source_dir} into #{source_dir}.old/"
  cp_r "#{themes_dir}/"+theme+"/source/.", source_dir, :remove_destination=>true
  cp_r "#{source_dir}.old/_includes/custom/.", "#{source_dir}/_includes/custom/", :remove_destination=>true
  cp "#{source_dir}.old/favicon.png", source_dir
  mv "#{source_dir}/index.html", "#{blog_index_dir}", :force=>true if blog_index_dir != source_dir
  cp "#{source_dir}.old/index.html", source_dir if blog_index_dir != source_dir && File.exists?("#{source_dir}.old/index.html")
  puts "## Updated #{source_dir} ##"
end

##############
# Deploying  #
##############

desc "Default deploy task"
task :deploy do
  # Check if preview posts exist, which should not be published
  if File.exists?(".preview-mode")
    puts "## Found posts in preview mode, regenerating files ..."
    File.delete(".preview-mode")
    Rake::Task[:generate].execute
  end

  Rake::Task[:copydot].invoke(source_dir, public_dir)
  Rake::Task["#{deploy_default}"].execute
end

desc "Generate website and deploy"
task :gen_deploy => [:integrate, :generate, :deploy] do
end

desc "Copy dot files for deployment"
task :copydot, :source, :dest do |t, args|
  FileList["#{args.source}/**/.*"].exclude("**/.", "**/..", "**/.DS_Store", "**/._*").each do |file|
    cp_r file, file.gsub(/#{args.source}/, "#{args.dest}") unless File.directory?(file)
  end
end

desc "Deploy website via rsync"
task :rsync do
  exclude = ""
  if File.exists?('./rsync-exclude')
    exclude = "--exclude-from '#{File.expand_path('./rsync-exclude')}'"
  end
  puts "## Deploying website via Rsync"
  ok_failed system("rsync -avze 'ssh -p #{ssh_port}' #{exclude} #{rsync_args} #{"--delete" unless rsync_delete == false} #{public_dir}/ #{ssh_user}:#{document_root}")
end

desc "Deploy public directory to github pages"
multitask :push do
  puts "## Deploying branch to Github Pages "
  puts "## Pulling any updates from Github Pages "
  cd "#{deploy_dir}" do
    Bundler.with_clean_env { system "git pull" }
  end
  (Dir["#{deploy_dir}/*"]).each { |f| rm_rf(f) }
  Rake::Task[:copydot].invoke(public_dir, deploy_dir)
  puts "\n## Copying #{public_dir} to #{deploy_dir}"
  cp_r "#{public_dir}/.", deploy_dir
  cd "#{deploy_dir}" do
    system "git add -A"
    message = "Site updated at #{Time.now.utc}"
    puts "\n## Committing: #{message}"
    system "git commit -m \"#{message}\""
    puts "\n## Pushing generated #{deploy_dir} website"
    Bundler.with_clean_env { system "git push origin #{deploy_branch}" }
    puts "\n## Github Pages deploy complete"
  end
end

desc "Update configurations to support publishing to root or sub directory"
task :set_root_dir, :dir do |t, args|
  puts ">>> !! Please provide a directory, eg. rake config_dir[publishing/subdirectory]" unless args.dir
  if args.dir
    if args.dir == "/"
      dir = ""
    else
      dir = "/" + args.dir.sub(/(\/*)(.+)/, "\\2").sub(/\/$/, '');
    end
    rakefile = IO.read(__FILE__)
    rakefile.sub!(/public_dir(\s*)=(\s*)(["'])[\w\-\/]*["']/, "public_dir\\1=\\2\\3public#{dir}\\3")
    File.open(__FILE__, 'w') do |f|
      f.write rakefile
    end
    compass_config = IO.read('config.rb')
    compass_config.sub!(/http_path(\s*)=(\s*)(["'])[\w\-\/]*["']/, "http_path\\1=\\2\\3#{dir}/\\3")
    compass_config.sub!(/http_images_path(\s*)=(\s*)(["'])[\w\-\/]*["']/, "http_images_path\\1=\\2\\3#{dir}/images\\3")
    compass_config.sub!(/http_fonts_path(\s*)=(\s*)(["'])[\w\-\/]*["']/, "http_fonts_path\\1=\\2\\3#{dir}/fonts\\3")
    compass_config.sub!(/css_dir(\s*)=(\s*)(["'])[\w\-\/]*["']/, "css_dir\\1=\\2\\3public#{dir}/stylesheets\\3")
    File.open('config.rb', 'w') do |f|
      f.write compass_config
    end
    jekyll_config = IO.read('_config.yml')
    jekyll_config.sub!(/^destination:.+$/, "destination: public#{dir}")
    jekyll_config.sub!(/^subscribe_rss:\s*\/.+$/, "subscribe_rss: #{dir}/atom.xml")
    jekyll_config.sub!(/^root:.*$/, "root: /#{dir.sub(/^\//, '')}")
    File.open('_config.yml', 'w') do |f|
      f.write jekyll_config
    end
    rm_rf public_dir
    mkdir_p "#{public_dir}#{dir}"
    puts "## Site's root directory is now '/#{dir.sub(/^\//, '')}' ##"
  end
end

desc "Set up _deploy folder and deploy branch for Github Pages deployment"
task :setup_github_pages, :repo do |t, args|
  if args.repo
    repo_url = args.repo
  else
    puts "Enter the read/write url for your repository"
    puts "(For example, 'git@github.com:your_username/your_username.github.io.git)"
    puts "           or 'https://github.com/your_username/your_username.github.io')"
    repo_url = get_stdin("Repository url: ")
  end
  protocol = (repo_url.match(/(^git)@/).nil?) ? 'https' : 'git'
  if protocol == 'git'
    user = repo_url.match(/:([^\/]+)/)[1]
  else
    user = repo_url.match(/github\.com\/([^\/]+)/)[1]
  end
  branch = (repo_url.match(/\/[\w-]+\.github\.(?:io|com)/).nil?) ? 'gh-pages' : 'master'
  project = (branch == 'gh-pages') ? repo_url.match(/([^\/]+?)(\.git|$)/i)[1] : ''
  unless (`git remote -v` =~ /origin.+?showcase(?:\.git)?/).nil?
    # If showcase is still the origin remote (from cloning) rename it to showcase
    system "git remote rename origin showcase"
    if branch == 'master'
      # If this is a user/organization pages repository, add the correct origin remote
      # and checkout the source branch for committing changes to the blog source.
      system "git remote add origin #{repo_url}"
      puts "Added remote #{repo_url} as origin"
      system "git config branch.master.remote origin"
      puts "Set origin as default remote"
      system "git branch -m master source"
      puts "Master branch renamed to 'source' for committing your blog source files"
    else
      unless !public_dir.match("#{project}").nil?
        system "rake set_root_dir[#{project}]"
      end
    end
  end
  url = blog_url(user, project, source_dir)
  jekyll_config = IO.read('_config.yml')
  jekyll_config.sub!(/^url:.*$/, "url: #{url}")
  File.open('_config.yml', 'w') do |f|
    f.write jekyll_config
  end
  rm_rf deploy_dir
  mkdir deploy_dir
  cd "#{deploy_dir}" do
    system "git init"
    system 'echo "My Showcase Page is coming soon &hellip;" > index.html'
    system "git add ."
    system "git commit -m \"Showcase init\""
    system "git branch -m gh-pages" unless branch == 'master'
    system "git remote add origin #{repo_url}"
    rakefile = IO.read(__FILE__)
    rakefile.sub!(/deploy_branch(\s*)=(\s*)(["'])[\w-]*["']/, "deploy_branch\\1=\\2\\3#{branch}\\3")
    rakefile.sub!(/deploy_default(\s*)=(\s*)(["'])[\w-]*["']/, "deploy_default\\1=\\2\\3push\\3")
    File.open(__FILE__, 'w') do |f|
      f.write rakefile
    end
  end
  puts "\n---\n## Now you can deploy to #{repo_url} with `rake deploy` ##"
end


################
# Rake Helpers #
################

def verify_installation(source_dir)
  unless File.directory?(source_dir)
    raise "### You haven't set anything up yet.
    First run 'rake install' to set up an Showcase theme."
  end
end

def write_new_page(file, front_matter = {})
  unless front_matter.is_a? Hash
    raise ArgumentError, "Invalid front matter format.
    Must contain 'variable: value'"
  end
  front_matter = { layout: "default" }.merge! front_matter

    File.open(file, 'w') do |page|
      page.puts "---"
      front_matter.each { |key ,value| page.puts "#{key}: #{value}" }
      page.puts "---"
    end
end

def dirname(path, base_dir = nil)
  dir_tree = []
  dir_tree << base_dir.downcase if base_dir

  unless path =~ /(^.+\/)?(.+)/
    raise "Syntax error: #{file} contains unsupported characters"
  end

  dir = $1 # captured from regex match
  if dir
    dir = dir.split('/').reject(&:empty?)
    dir_tree += dir
  end
  dir = dir_tree.map { |d| d && d = d.to_url }.join('/')

  dir
end

def blog_url(user, project, source_dir)
  cname = "#{source_dir}/CNAME"
  url = if File.exists?(cname)
    "http://#{IO.read(cname).strip}"
  else
    "http://#{user.downcase}.github.io"
  end
  url += "/#{project}" unless project == ''
  url
end

desc "List tasks"
task :list do
  puts "Tasks: #{(Rake::Task.tasks - [Rake::Task[:list]]).join(', ')}"
  puts "(type rake -T for more detail)\n\n"
end
