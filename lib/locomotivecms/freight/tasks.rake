require 'nokogiri'
require 'locomotive/coal'
require 'yaml'
require 'pry'
require 'locomotivecms/freight/wordpress_importer'

namespace :wp do
  task testing: :importer do
    binding.pry
  end

  task all_the_links: [:importer, :input_file] do
    puts @importer.all_links(@input_file).join("\n")
  end

  task all_the_images: [:importer, :input_file] do
    puts @importer.all_images(@input_file).join("\n")
  end

  task all_the_tables: [:importer, :input_file] do
    puts @importer.all_tables(@input_file).join("\n")
  end

  task remove_non_visible: :importer do
    @importer.remove_non_visible_posts!
  end

  desc "remove all WordPress posts from the targeted environment"
  task clean: :importer do
    @importer.clean!
  end

  desc "import WordPress export xml"
  task import: [:importer, :input_file] do
    @importer.import @input_file
    @importer.rewrite_internal_urls
    @importer.rewrite_images
  end

  desc "clean and then re-import"
  task reload: [:clean, :import]

  task input_file: :importer do
    @input_file = ENV['XML'] || ENV['XML_FILE'] || ENV['FILE']

    unless @input_file
      raise "You must provide an xml file by adding 'XML=/path/to/my.xml'"
    end
  end

  task importer: :client do
    @importer = WordpressImporter.new @client
  end

  task client: :config do
    @client = Locomotive::Coal::Client.new(@host, { email: @email, api_key: @api_key }).scope_by(@handle)
  end

  task :config do
    target_env = ENV['TARGET']
    config = YAML.load(File.read('config/deploy.yml'))

    unless target_env && config.keys.include?(target_env)
      raise "you must set the target environment, one of #{config.keys.join(', ')}"
    end

    @host    = config[target_env]['host']
    @handle  = config[target_env]['handle']
    @email   = config[target_env]['email']
    @api_key = config[target_env]['api_key']
  end

end # namespace :wp


