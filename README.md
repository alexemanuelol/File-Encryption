# File-Encryption
A simple cryptography program that handles encryption/decryption of a file using a password (AES).

# Setup

```bash
$ git clone https://github.com/alexemanuelol/File-Encryption.git
$ cd File-Encryption
$ bundle install
```

# Usage
Basic usage:

```bash
$ ruby crypto.rb --encrypt file.txt --password secretPassword --output file_encrypted.txt

$ ruby crypto.rb --decrypt file_encrypted.txt --password secretPassword --output original_file.txt
```