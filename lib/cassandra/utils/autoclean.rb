require 'socket'

module Cassandra
  module Utils
   class Autoclean
     def run!
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
       if @address.nil? || @address.empty?
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
   end
  end
end
