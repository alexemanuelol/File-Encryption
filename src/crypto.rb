#!/usr/bin/env ruby

#
#   This script is used to either encrypt or decrypt a file using AES
#

require 'openssl'
require 'base64'
require 'optparse'


class Cryptography
    # Cryptography class

    def initialize()
    end

    def encrypt_data(data, password)
        cipher = OpenSSL::Cipher::Cipher.new('AES-256-CBC')
        cipher.encrypt
        cipher.key = OpenSSL::Digest::SHA256.new(password).digest
        return Base64.encode64(cipher.update(data.to_s.strip) + cipher.final)
    end

    def encrypt_file(path, password)
        dirname = File.dirname(path)
        filename = File.basename(path, '.*')
        extension = File.extname(path)
        output = dirname + '/' + filename + '_encrypted' + extension

        buf = ''
        File.open(output, 'wb') do |outf|
            File.open(path, 'rb') do |inf|
                data = inf.read
                encrypted = self.encrypt_data(data, password)
                outf.write(encrypted)
            end
        end
    end

    def decrypt_data(data, password)
        base64_decoded = Base64.decode64(data.to_s.strip)
        cipher = OpenSSL::Cipher::Cipher.new('AES-256-CBC')
        cipher.decrypt
        cipher.key = OpenSSL::Digest::SHA256.new(password).digest
        return cipher.update(base64_decoded) + cipher.final
    end

    def decrypt_file(path, password)
        dirname = File.dirname(path)
        filename = File.basename(path, '.*')
        extension = File.extname(path)
        output = dirname + '/' + filename + '_decrypted' + extension

        File.open(output, 'wb') do |outf|
            File.open(path, 'rb') do |inf|
                data = inf.read
                decrypted = self.decrypt_data(data, password)
                outf.write(decrypted)
            end
        end
    end
end


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

            opts.on("-p", "--password PASSWORD", "The password for encrypt/decrypt.") do |password|
                options[:password] = password
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

        if options.empty?
            puts opts
            exit 1
        end

        if !options.key?(:password)
            puts 'Password is required.'
            puts opts
            exit 1
        end

        if !options.key?(:encrypt) && !options.key?(:decrypt)
            puts 'Choose file to encrypt/decrypt.'
            puts opts
            exit 1
        end

        return options
    end
end


options = ArgParser.parse(ARGV)
crypt = Cryptography.new()

begin
    if options.key?(:encrypt)
        crypt.encrypt_file(options[:encrypt], options[:password])
        puts 'Successfully encrypted.'
    elsif options.key?(:decrypt)
        crypt.decrypt_file(options[:decrypt], options[:password])
        puts 'Successfully decrypted.'
    end
rescue Exception => e
    if options.key?(:encrypt)
        puts "Could not successfully encrypt file: #{options[:encrypt]}"
    elsif options.key?(:decrypt)
        puts "Could not successfully decrypt file: #{options[:decrypt]}"
        puts 'Password might be wrong.'
    end
end