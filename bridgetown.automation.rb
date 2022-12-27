# My thanks to Jared White's Bulmatown plugin from whom I stole most of this
# but then HEAVILY restructured
#
# Current structure is
# 1. def methods
# 2. plugins
# 3. requirements
# 4. Front End
# 5. Everything Else

#
# TO TEST THIS AUTOMATION, just run
# 
#  bin/bridgetown apply https://github.com/fuzzygroup/brinima
#
# AFTER IT IS COMMITTED TO GIT AND YOU WAIT 5 minutes for any server side git sync

#
# START DEF METHODS
#

#
# Check if a given gem is already installed
#
=begin
Need to adjust this to handle version issues

[!] There was an error parsing `injected gems`: You cannot specify the same gem twice with different version requirements.
You specified: bridgetown-quick-search (~> 1.1) and bridgetown-quick-search (>= 0). Gem already added. Bundler cannot continue.

 #  from injected gems:1
 #  -------------------------------------------
 >  gem "bridgetown-quick-search", ">= 0", :group => :bridgetown_plugins
 #  -------------------------------------------
         run    Gem not added due to bundler error
  Exception raised: Errno::ENOENT
No such file or directory @ dir_s_mkdir - src/theme_backups/20221218132228/src/_components

=end
def gem_installed?(gem_name)
  #https://stackoverflow.com/questions/22211711/how-to-check-if-a-gem-is-installed
  # gem query --silent --installed --exact rubygems --version 2.0.0
  result = `gem list #{gem_name}`
  return true if result =~ /#{gem_name}/
  false
end

#
# Create a backup directory for theme files and copy data over to it
#
# NOTE: This works purely locally so normal Ruby file operations apply
#
def backup_existing_theme_files
  unless Dir.exist? MASTER_BACKUP_DIR
    # generate a master backup directory  
    FileUtils.mkdir_p MASTER_BACKUP_DIR
  end
  
  # generate timestamp
  backup_time_stamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
  backup_time_stamp = '20221218132228'
  
  backup_directory = File.join(MASTER_BACKUP_DIR, backup_time_stamp)
  
  #TODO - error handling
  unless Dir.exist?(backup_directory)
    FileUtils.mkdir(backup_directory)
  end
  # copy all files from directorys
  source_directories = []
  source_directories << "src/_components"
  source_directories << "src/_layouts"
  # TODO -- javascript and css

  # copy files from sources
  source_directories.each do |source_dir|
    destination_dir = File.join(backup_directory, source_dir)
    #TODO - error handling
    unless Dir.exist?(destination_dir)
      FileUtils.mkdir_p(destination_dir)
    end
    Dir.glob(File.join(source_dir, '*')).each do |f|
      FileUtils.cp f, destination_dir unless File.exists?(File.join(destination_dir, f))
    end
  end
  
  # Copy metadata over before it is modified
  source_dir = "src/_data/"
  destination_dir = File.join(backup_directory, source_dir)
  unless Dir.exist?(destination_dir)
    FileUtils.mkdir_p(destination_dir)
  end
  FileUtils.cp File.join('src/_data', 'site_metadata.yml'), destination_dir
  
  #
  # Now remove existing files 
  #
  puts "Now removing existing files except for site_metadata.yml"
  directories_of_all_files_to_delete = []
  directories_of_all_files_to_delete << 'src/_components'
  directories_of_all_files_to_delete << 'src/_layouts'
  directories_of_all_files_to_delete.each do |dir|
    Dir.glob(File.join(dir, '*')).each do |f|
      FileUtils.rm(f) if File.exists?(f)
    end
  end
  
  single_files_to_delete = []
  single_files_to_delete << File.join('src', 'index.md')
  single_files_to_delete << File.join('src', 'posts.md')
  single_files_to_delete.each do |f|
    FileUtils.rm(f) if File.exists?(f)
  end
end

#
# Tests if in development mode like Rails.development?
#
def bridgetown_development?
  return true if Dir.exist?("/Users/sjohnson/")
end



#
# Create a backup directory for frontend files and copy data over to it
# this backup directory is UNDER the MASTER_BACKUP_DIR to avoid issues
# with build compliation
#
# TODO (future): dry up this code; largely redundant with other backup routine
#
# NOTE: This works purely locally so normal Ruby file operations apply
#
def backup_existing_frontend_files
  
  unless Dir.exist? MASTER_FRONTEND_BACKUP_DIR
    # generate a master backup directory  
    FileUtils.mkdir_p MASTER_FRONTEND_BACKUP_DIR
  end
  
  # generate timestamp
  backup_time_stamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
  # hacky way to check for dev mode; look for my personal home dir
  backup_time_stamp = '20221218132228' if bridgetown_development?
  
  backup_directory = File.join(MASTER_FRONTEND_BACKUP_DIR, backup_time_stamp)
  
  #TODO - error handling
  unless Dir.exist?(backup_directory)
    FileUtils.mkdir(backup_directory)
  end
  # copy all files from directorys
  source_directories = []
  source_directories << "frontend/styles"
  source_directories << "frontend/javascript"
  source_directories << "frontend/fonts"
  # TODO -- javascript and css

  # copy files from sources
  source_directories.each do |source_dir|
    destination_dir = File.join(backup_directory, source_dir)
    #TODO - error handling
    unless Dir.exist?(destination_dir)
      FileUtils.mkdir_p(destination_dir)
    end
    Dir.glob(File.join(source_dir, '*')).each do |f|
      FileUtils.cp f, destination_dir unless File.exists?(File.join(destination_dir, f))
    end
  end
  
  #
  # Now remove existing files 
  #
  puts "Now removing existing files except for site_metadata.yml"
  directories_of_all_files_to_delete = []
  directories_of_all_files_to_delete << 'frontend/styles'
  directories_of_all_files_to_delete << 'frontend/javascript'
  directories_of_all_files_to_delete << 'frontend/fonts'
  directories_of_all_files_to_delete.each do |dir|
    Dir.glob(File.join(dir, '*')).each do |f|
      FileUtils.rm(f)
    end
  end
  
end

#
# NOTE: This works FROM github so uses copy_file to move the file over
#

def install_theme_files
  #
  # Move the source repo local
  #
  add_template_repository_to_source_path
  
  #copy_file "example/src/_layouts/#{file}.liquid", target
  
  #
  # Install all frontend files
  #
  # install_theme_files("src/frontend/javascript", "frontend/javascript")
  # install_theme_files("src/frontend/styles", "frontend/styles")
  #
  #
  # #
  # # Install all src/_components files -- footer.liquid  head.liquid  navbar.liquid
  # #
  # install_theme_files("src/components", "src/_components")
  #copy_file "example/src/components/#{file}.liquid", target
  copy_file "example/src/components/footer.liquid", "src/_components/footer.liquid"
  #copy_file "example/src/components/head.liquid", "src/_components/head.liquid"
  #copy_file "example/src/components/navbar.liquid", "src/_components/navbar.liquid"
  #
  #
  # #
  # # Install all src/_layouts files -- default.liquid  page.liquid  post.liquid
  # #
  # install_theme_files("src/layouts", "src/_layouts")

  
  
end

# Copied from: https://github.com/mattbrictson/rails-template
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require 'tmpdir'

    source_paths.unshift(tempdir = Dir.mktmpdir(DIR_NAME + '-'))
    #TODO restore this
    at_exit { FileUtils.remove_entry(tempdir) } if !bridgetown_development?
    run("git clone --quiet #{GITHUB_PATH.shellescape} #{tempdir.shellescape}")
    puts "\n\n\n\n"
    puts "tempdir = #{tempdir}"
    puts "\n\n\n\n"

    if (branch = __FILE__[%r{#{DIR_NAME}/(.+)/bridgetown.automation.rb}, 1])
      Dir.chdir(tempdir) { system("git checkout #{branch}") }
      @current_dir = File.expand_path(tempdir)
    end
  else
    source_paths.unshift(DIR_NAME)
  end
end

def copy_if_exists(file)
  target = File.exist?("src/_layouts/#{file}.html") ? "src/_layouts/#{file}.html" : "src/_layouts/#{file}.liquid"
  copy_file "example/src/_layouts/#{file}.liquid", target
end

def substitute_in_default_if_exists
  if File.exists?("src/_layouts/default.liquid")
    gsub_file "src/_layouts/default.liquid", '{% render "footer", ', '{% render "footer", url: site.url, '
  elsif File.exists?("src/_layouts/default.html")
    gsub_file "src/_layouts/default.html", '{% render "footer", ', '{% render "footer", url: site.url, '
  else
    say_status :bulmatown, "Could not find the default template. You will have to add the url parameter to the render command manually"
  end
end



#
# END DEF METHODS
#

























#
# END TO END FLOW
#

#
# PLUGINS
# 
# add_bridgetown_plugin "brinima" unless gem_installed?("brinima")
add_bridgetown_plugin "bridgetown-quick-search" unless gem_installed?("bridgetown-quick-search")
add_bridgetown_plugin "bridgetown-feed" unless gem_installed?("bridgetown-feed")


#add_yarn_for_gem "bulmatown"


#
# REQUIREMENTS
#
require 'fileutils'
require 'shellwords'


#
# FRONT END
#
#run "cp node_modules/fork-awesome/fonts/* frontend/fonts"

#javascript_import 'import Bulmatown from "bulmatown"'

# *** Set up remote repo pull



# Dynamically determined due to having to load from the tempdir
@current_dir = File.expand_path(__dir__)

# If its a remote file, the branch is appended to the end, so go up a level
ROOT_PATH = if __FILE__ =~ %r{\Ahttps?://}
              File.expand_path('../', __dir__)
            else
              File.expand_path(__dir__)
            end

DIR_NAME = File.basename(ROOT_PATH)

# DIR_NAME = 'brinima'
GITHUB_PATH = "https://github.com/fuzzygroup/#{DIR_NAME}.git"

THEME_NAME = "brinima"



# unless Dir.exist? "frontend/fonts"
#   FileUtils.mkdir_p "frontend/fonts"
# end

MASTER_BACKUP_DIR = "src/theme_backups"
MASTER_FRONTEND_BACKUP_DIR = "src/theme_backups/frontend"

#
# Backup all existing theme files
#
backup_existing_theme_files
backup_existing_frontend_files

#
# Install all theme files
#
install_theme_files



#
# Install Back of Blog Index files -- 
#
#TODO

#
# Install Index to Podcasts 
#
#TODO


#
# Install Index to YouTube
#
#TODO


#
# Install Index to Twitter Links
#
#TODO



#raise "Foo -- test if the backup worked!!!"







if yes? "The Bulmatown installer can update styles, layouts, and page templates to use the new theme. You'll have the option to type 'a' to overwrite all existing files or 'd' to inspect each change. Would you like to proceed? (Y/N)"
  add_template_repository_to_source_path

  create_file "frontend/styles/index.scss", '@import "~bulmatown/frontend/styles"'
  #debugger
  ["home", "page", "post"].each { |f| copy_if_exists(f) }
  substitute_in_default_if_exists

  copy_file "example/src/index.md", "src/index.md"
  copy_file "example/src/posts.md", "src/posts.md"
  copy_file "example/src/404.html", "src/404.html"
  
  copy_file "example/src/_components/navbar.liquid", "src/_components/navbar.liquid"
  copy_file "example/src/_components/footer.liquid", "src/_components/footer.liquid"

  inject_into_file "bridgetown.config.yml", "pagination:\n  enabled: true\n", after: "permalink: pretty\n"
end

twitter = ask "Do you have a Twitter handle? If so, enter it here, otherwise type 'no'"

if twitter != "" && twitter != "no"
  append_to_file "src/_data/site_metadata.yml" do
    <<~YAML

      twitter: #{twitter}

    YAML
  end
end

say_status :bulmatown, "Theme installation complete! Enjoy your fresh new design :)"

if yes? "Every blog has a table of contents -- the index.md template -- which can EITHER list all posts as a table of contents (just links to every post) -or- list the full content of your last 10 posts and then link to all posts (using the posts.md template).  Type Y if you want to list the full content of your last 10 posts or N to just have a table of contents.  Side note: If you have lots of long posts then you likely want to say N"
else
end

# copy over readme_brinima.md to 
