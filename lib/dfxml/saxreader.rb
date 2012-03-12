require 'sax-machine'
require 'time'

def parse_iso8601 value
  begin
    Time.iso8601(value)
  rescue
    warn "Failed to parse date #{value.inspect}"
    value
  end
end


module Dfxml
  
  module SAXReader

    class IndividualRun
      include SAXMachine
      attribute :file_offset
      attribute :fs_offset
      attribute :img_offset
      attribute :len
    end
    
    class ByteRun
      include SAXMachine
      elements :byte_run, :as => :runs, :class => IndividualRun
    end

    class FileObject
      include SAXMachine
      element :alloc
      element :atime
      element :compressed
      element :crtime
      element :ctime
      element :dtime
      element :encrypted
      element :filename
      element :filesize
      element :fragments
      element :gid
      element :id, :as => :fileid
      element :inode
      element :libmagic
      element :meta_type
      element :mode
      element :mtime
      element :name_type
      element :nlink
      element :partition
      element :uid
      element :unalloc
      element :used
      element :byte_runs, :class => ByteRun
      element :hashdigest, :as => :md5, :with => {:type => "md5"}
      element :hashdigest, :as => :sha1, :with => {:type => "sha1"}
      # elements from fido extractor plugin
      # element "PUID", :as => :pronom_puid
      # element "PronomFormat", :as => :pronom_format
      
      def atime=(val)
        @atime = parse_iso8601 val
      end
      
      def crtime=(val)
        @crtime = parse_iso8601 val
      end
      
      def dtime=(val)
        @dtime = parse_iso8601 val
      end
      
      def mtime=(val)
        @mtime = parse_iso8601 val
      end
      
    end

    class Volume
      include SAXMachine
      attribute :offset
      element :partition_offset
      element :block_size
      element :ftype_str, :as => :ftype
      element :block_count
      element :first_block
      element :last_block
      element :allocated_only
      elements :fileobject, :as => :fileobjects, :class => FileObject
    end
    
    class ExecutionEnvironment
      include SAXMachine
      element :os_sysname
      element :os_release
      element :os_version
      element :host
      element :arch
      element :command_line
      element :start_time
    end
    
    class BuildLibrary
      include SAXMachine
      attribute :name
      attribute :version
    end
    
    class BuildEnvironment
      include SAXMachine
      element :compiler
      elements :library, :as => :libraries, :class => BuildLibrary
    end
    
    class Creator
      include SAXMachine
      element :program
      element :version
      element :build_environment, :class => BuildEnvironment
      element :execution_environment, :class => ExecutionEnvironment
    end
    
    class Source
      include SAXMachine
      element :image_filename
    end
    
    class Metadata
      include SAXMachine
      element "dc:type", :as => :type
    end
    
    class RuntimeStatistics
      include SAXMachine
      element :user_seconds
      element :system_seconds
      element :maxrss
      element :reclaims
      element :faults
      element :swaps
      element :inputs
      element :outputs
      element :stop_time
    end
    
    class DFXML
      include SAXMachine
      attribute :version
      element :metadata, :class => Metadata
      element :creator, :class => Creator
      element :source, :class => Source
      elements :volume, :as => :volumes, :class => Volume
      element :runstats, :class => RuntimeStatistics
    end  
  end
  
end