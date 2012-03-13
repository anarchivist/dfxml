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
      element :alloc, :as => :allocated
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
      element :id_
      element :inode
      element :libmagic
      #element :meta_type # ignore meta_type. values in TSK_FS_META_TYPE_ENUM
      element :mode
      element :mtime
      element :name_type, :as => :type
      element :nlink
      element :partition
      element :uid
      element :unalloc, :as => :unallocated
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
      
      # We have to check for the presence of both alloc AND unalloc tags
      # to determine whether the directory entry is actually allocated, given
      # the weird way in which fiwalk tends to dump out this information
      def allocated=(val)
        @allocated = true ? val == '1' : false
      end
      
      def unallocated=(val)
        @allocated ||= false if val == '1'
      end
      
      def allocated?
        @allocated
      end
      
      # functions of these forms don't work because they'll never get called
      # unless the corresponding element exists. sax-machine should have a
      # way to insert default values when appropriate.
      # def compressed=(val)
      #   @compressed = false ? val.nil? : true
      # end
      # 
      # def compressed?
      #   @compressed
      # end
      
      def crtime=(val)
        @crtime = parse_iso8601 val
      end
      
      def dtime=(val)
        @dtime = parse_iso8601 val
      end
      
      def mtime=(val)
        @mtime = parse_iso8601 val
      end
      
      def type=(val)
        @type = {
          '-' => :unknown,
          'r' => :file,
          'd' => :directory,
          'c' => :character_device,
          'b' => :block_device,
          'l' => :symlink,
          'p' => :named_pipe,
          's' => :shadow,
          'h' => :socket,
          'w' => :whiteout,
          'v' => :tsk_virtual_file
        }[val]
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