require 'socket'
require 'json'
require 'time'

module Cassandra
  module Utils
   class Autoclean
     def run!
     end

     def save_tokens
       data = {
         :timestamp => Time.now.iso8601,
         :tokens => tokens,
         :version => ::Cassandra::Utils::VERSION
       }

       token_cache.write data.to_json
       token_cache.flush
     end

     # Get the tokens this node owns
     #
     # The "nodetool ring" command returns
     #
     # Address    Rack  Status  State   Load  Size  Owns  Token
     # 127.0.0.1  r1    Up      Normal  10    GB    33%   123456789
     #
     # @return [Array<String>] Tokens owned by this node
     #
     def tokens
       return [] if address.nil?
       results = (nodetool_ring || '').split("\n")
       results.map! { |line| line.strip }
       results.select! { |line| line.start_with? address }
       results.map! { |line| line.split(/\s+/)[7] }
       results.compact!
       results.sort
     end

     # Get the IP address of this node
     #
     # @return [String, nil] IP address of this node
     #
     def address
       if @address.nil?
         addr = Socket.ip_address_list.find { |addr| addr.ipv4_private? }
         @address = addr.ip_address unless addr.nil?
       end
       @address
     end

     private

     # Run the "nodetool ring" command and return the output
     #
     # @return [String, nil] Output from the "nodetool ring" command
     #
     def nodetool_ring
       @nodetool_ring ||= Mixlib::ShellOut.new('nodetool ring', {
         :cwd => '/tmp',
         :timeout => 120
       })
       @nodetool_ring.run_command
       @nodetool_ring.error!
       @nodetool_ring.stdout
     end

     # Get the cache tokens wil be saved in
     #
     # @return [File] File where tokens wil be saved
     #
     def token_cache
       File.new('/tmp/autoclean-tokens.json')
     end
   end
  end
end
