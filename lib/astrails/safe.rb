require "aws/s3"
require 'cloudfiles'
require 'net/sftp'
require 'fileutils'
require 'benchmark'

require 'yaml'

require 'tempfile'
require File.dirname(__FILE__) + '/../extensions/mktmpdir'

require File.dirname(__FILE__) + '/safe/tmp_file'

require File.dirname(__FILE__) + '/safe/config/node'
require File.dirname(__FILE__) + '/safe/config/builder'

require File.dirname(__FILE__) + '/safe/stream'

require File.dirname(__FILE__) + '/safe/backup'

require File.dirname(__FILE__) + '/safe/backup'

require File.dirname(__FILE__) + '/safe/source'
require File.dirname(__FILE__) + '/safe/mysqldump'
require File.dirname(__FILE__) + '/safe/pgdump'
require File.dirname(__FILE__) + '/safe/archive'
require File.dirname(__FILE__) + '/safe/svndump'

require File.dirname(__FILE__) + '/safe/pipe'
require File.dirname(__FILE__) + '/safe/gpg'
require File.dirname(__FILE__) + '/safe/gzip'

require File.dirname(__FILE__) + '/safe/sink'
require File.dirname(__FILE__) + '/safe/local'
require File.dirname(__FILE__) + '/safe/s3'
require File.dirname(__FILE__) + '/safe/sftp'

require File.dirname(__FILE__) + '/safe/rcloud'

module Astrails
  module Safe
    ROOT = File.join(File.dirname(__FILE__), "..", "..")

    def safe(&block)
      config = Config::Node.new(&block)
      #config.dump
      
      [[Mysqldump, [:mysqldump, :databases]],
       [Pgdump,    [:pgdump,    :databases]],
       [Archive,   [:tar,       :archives]],
       [Svndump,   [:svndump,   :repos]]
      ].each do |klass, path|
        if collection = config[*path]
          collection.each do |name, config|
            klass.new(name, config).backup.run(config, :gpg, :gzip, :local, :s3, :sftp, :rcloud)
          end
        end
      end

      Astrails::Safe::TmpFile.cleanup
    end
    module_function :safe
  end
end
