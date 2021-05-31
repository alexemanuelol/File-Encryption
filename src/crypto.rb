#!/usr/bin/env ruby

#
#   This script is used to either encrypt or decrypt a file using AES
#

require 'optparse'


class ArgParser
    # Handles incoming CLI arguments

    def self.parse(args)
        options = {}
        opts = OptionParser.new do |opts|
            opts.banner = "Usage: #{__FILE__} [option...]"

            opts.on("-e", "--encrypt FILE", "File to be encrypted.") do |encrypt|
                if options.has_key?(:decrypt)
                    puts "You cannot encrypt and decrypt at one go!"
                    puts opts
                    exit 1
                end
                options[:encrypt] = encrypt
            end

            opts.on("-d", "--decrypt FILE", "File to be decrypted.") do |decrypt|
                if options.has_key?(:encrypt)
                    puts "You cannot decrypt and encrypt at one go!"
                    puts opts
                    exit 1
                end
                options[:decrypt] = decrypt
            end

            opts.on("-h", "--help", "Display this help text and exit.") do
                puts opts
                exit
            end
        end
            opts.parse(args)
        begin
        rescue Exception => e
            puts "Exception encountered: #{e}"
            puts opts
            exit 1
        end

        return options
    end
end


options = ArgParser.parse(ARGV)
puts options