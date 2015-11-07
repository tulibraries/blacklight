module Blacklight
  class PluginTestSupport < Rails::Generators::Base

    source_root File.expand_path('../../../../', __FILE__)

    def inject_engine_cart
      inject_into_file "#{File.basename(destination_root)}.gemspec", before: "end\n" do <<-EOF
  s.add_development_dependency "engine_cart"
  s.add_development_dependency "solr_wrapper"
      EOF
      end
    end

    def inject_rspec
      return if File.new("#{File.basename(destination_root)}.gemspec").any? {|l| l.include? "rspec-rails" }

      inject_into_file "#{File.basename(destination_root)}.gemspec", before: "end\n" do <<-EOF
  s.add_development_dependency "rspec-rails", "~> 3.0"
  s.add_development_dependency "capybara"
      EOF
      end
    end

    def bundle_install
      Bundler.with_clean_env do
        run "bundle install"
      end
    end

    def install_rspec
      generate 'rspec:install'
    end

    def inject_rake_tasks
      append_to_file 'Rakefile' do <<-EOF.strip_heredoc
        require 'rspec/core/rake_task'
        RSpec::Core::RakeTask.new(:spec)

	require 'engine_cart/rake_task'

	ZIP_URL = "https://github.com/projectblacklight/blacklight-jetty/archive/v4.10.4.zip"
	require 'solr_wrapper'

	task :default => [:ci]

	EngineCart.fingerprint_proc = EngineCart.rails_fingerprint_proc

	desc "Run test suite"
	task :ci => ['engine_cart:generate'] do
	  SolrWrapper.wrap(port: '8888') do |solr|
	    solr.with_collection(name: 'blacklight-core', dir: File.join(File.expand_path(File.dirname(__FILE__)), "solr", "conf")) do
	      Rake::Task['spec'].invoke
	    end
	  end
	end
      EOF
      end
    end

    def engine_cart_prepare
      system "bundle exec rake engine_cart:prepare"
    end

    def inject_engine_cart_in_rspec
      inject_into_file 'spec/rails_helper.rb', after: "require 'spec_helper'\n" do <<-EOF.strip_heredoc
        require 'engine_cart'
        EngineCart.load_application!
      EOF
      end
      inject_into_file 'spec/rails_helper.rb', after: "# Add additional requires below this line. Rails is not loaded until this point!\n" do <<-EOF.strip_heredoc
        require 'capybara/poltergeist'
        Capybara.javascript_driver = :poltergeist
      EOF
      end
    end

    def install_solr_conf
      directory 'solr', 'solr'
    end

  end
end
