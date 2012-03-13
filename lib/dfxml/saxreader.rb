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

def isone?(val)
  # Return true if something is one (number or string).
  # Vased on Python isone function packaged in fiwalk's dfxml.py
  # Unlike Python, we probably don't need to catch a TypeError exception.
  true ? val.to_i == 1 : false
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
      
      # Begin boolean methods
      #
      # Convenience methods for flags expressed in the metadata layer of
      # file systems. However, they're not terribly robust and are considered
      # workarounds for the way fiwalk expresses metadata-layer flags in
      # its output. In fiwalk-generated dfxml, when an element should be
      # considered true, the element contains the value "1". However, the
      # expression in output doesn't necessarily fit with what humans expect.
      # For example, the allocated/unallocated flags are expressed in
      # fiwalk's output as follows:
      #
      # - when allocated: <alloc>1</alloc>
      # - when unallocated: <unalloc>1</unalloc>
      # 
      # For more clarification, see fiwalk_tsk.cpp's handling for
      # fs_file->meta in process_tsk_file.
            
      def allocated?
        isone?(@alloc) && !isone?(@unalloc)
      end
      
      def compressed?
        isone?(@compressed)
      end
      
      def encrypted?
        # encrypted is not a flag, but we'll treat it like one.
        isone?(@encrypted)
      end
      
      def orphan?
        isone?(@orphan)
      end
      
      def used?
        isone?(@used) && !isone?(@unused)
      end
      
      # End boolean methods      
      
      def type
        # def meta_type=(val)
        #   @meta_type ||= Dfxml::NumericFileTypes[val.to_i]
        # end
        # 
        # def name_type=(val)
        #   @name_type ||= Dfxml::CharacterFileTypes[val]
        # end
        
        Dfxml::CharacterFileTypes[@name_type] ||= Dfxml::NumericFileTypes[@meta_type.to_i]
      end
      
    end

    class Volume
      include SAXMachine
      attribute :offset
      element :partition_offset
      element :block_size
      element :ftype
      element :ftype_str      
      element :block_count
      element :first_block
      element :last_block
      element :allocated_only
      elements :fileobject, :as => :fileobjects, :class => FileObject
      
      def ftype=(val)
        @ftype ||= Dfxml::NumericFileSystemTypes[val.to_i]
      end
      
      def ftype_str=(val)
        @ftype ||= val.to_sym
      end
      
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