require 'highline/import'

Capistrano::Configuration.instance(true).load do
  set :database_name, nil
  set :database_user, Proc.new { Highline.ask("What is your database username?  ") { |q| q.default = "dbuser" } }
  set :database_pass, Proc.new { Highline.ask("What is your database password?  ") { |q| q.echo = "*" } }
  
  namespace :database do
    task :configure do
      db_config =<<EOF
production:
  adapter: mysql
  database: #{database_name}
  username: #{database_user}
  password: #{database_pass}
  host: 127.0.0.1
EOF
      run "if test ! -d #{shared_path}/config/; then mkdir -p #{shared_path}/config/; fi"
      put db_config, "#{shared_path}/config/database.yml"
    end
    
    task :copy_config do
      on_rollback {
        puts "*** File shared/config/database.yml is missing. ***"
        puts "*** Run cap database:configure to generate and upload. ***"
      }
      
      run "cp #{shared_path}/config/database.yml #{release_path}/config/"
    end
  end
end
