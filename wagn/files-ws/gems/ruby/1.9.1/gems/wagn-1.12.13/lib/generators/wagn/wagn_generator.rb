require 'rails/generators/app_base'

class WagnGenerator < Rails::Generators::AppBase

#class WagnGenerator < Rails::Generators::AppGenerator

  source_root File.expand_path('../templates', __FILE__)
  
  class_option :database, :type => :string, :aliases => "-d", :default => "mysql",
    :desc => "Preconfigure for selected database (options: #{DATABASES.join('/')})"
  
  public_task :create_root
  
## should probably eventually use rails-like AppBuilder approach, but this is a first step.  
  
  def rakefile
    template "Rakefile"
  end

#  def readme
#    copy_file "README", "README.rdoc"
#  end
  
  def mods
    empty_directory_with_gitkeep 'mods'
  end
  
  def log
    empty_directory_with_gitkeep 'log'
  end
  
  def files
    empty_directory_with_gitkeep 'files'
  end
  
  def tmp
    empty_directory 'tmp'
  end
    
  def gemfile
    template "Gemfile"
  end

  def configru
    template "config.ru"
  end
  
  def gitignore
    copy_file "gitignore", ".gitignore"
  end
  
  def config
    empty_directory "config"

    inside "config" do
      template "application.rb"
      template "environment.rb"
      template "boot.rb"
      template "databases/#{options[:database]}.yml", "database.yml"  
    end
    
  end
  
  def script
    directory "script" do |content|
      "#{shebang}\n" + content
    end
    chmod "script", 0755 & ~File.umask, :verbose => false
  end
  
  public_task :run_bundle
  
  protected
  
  def mysql_socket
    @mysql_socket ||= [
      "/tmp/mysql.sock",                        # default
      "/var/run/mysqld/mysqld.sock",            # debian/gentoo
      "/var/tmp/mysql.sock",                    # freebsd
      "/var/lib/mysql/mysql.sock",              # fedora
      "/opt/local/lib/mysql/mysql.sock",        # fedora
      "/opt/local/var/run/mysqld/mysqld.sock",  # mac + darwinports + mysql
      "/opt/local/var/run/mysql4/mysqld.sock",  # mac + darwinports + mysql4
      "/opt/local/var/run/mysql5/mysqld.sock",  # mac + darwinports + mysql5
      "/opt/lampp/var/mysql/mysql.sock"         # xampp for linux
    ].find { |f| File.exist?(f) } unless RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
  end
  
  ### the following is straight from rails and is focused on checking the validity of the app name.
  ### needs wagn-specific tuning
  
  
  def app_name
    @app_name ||= defined_app_const_base? ? defined_app_name : File.basename(destination_root)
  end

  def defined_app_name
    defined_app_const_base.underscore
  end

  def defined_app_const_base
    Rails.respond_to?(:application) && defined?(Rails::Application) &&
      Wagn.application.is_a?(Rails::Application) && Wagn.application.class.name.sub(/::Application$/, "")
  end

  alias :defined_app_const_base? :defined_app_const_base
  
  def app_const_base
    @app_const_base ||= defined_app_const_base || app_name.gsub(/\W/, '_').squeeze('_').camelize
  end
  alias :camelized :app_const_base
  
  def app_const
    @app_const ||= "#{app_const_base}::Application"
  end

  def valid_const?
    if app_const =~ /^\d/
      raise Error, "Invalid application name #{app_name}. Please give a name which does not start with numbers."
#    elsif RESERVED_NAMES.include?(app_name)
#      raise Error, "Invalid application name #{app_name}. Please give a name which does not match one of the reserved rails words."
    elsif Object.const_defined?(app_const_base)
      raise Error, "Invalid application name #{app_name}, constant #{app_const_base} is already in use. Please choose another application name."
    end
  end
  
end
