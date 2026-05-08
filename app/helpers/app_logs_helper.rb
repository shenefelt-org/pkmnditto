unless defined?(Fixnum)
  Fixnum = Integer
end

unless defined?(Bignum)
  Bignum = Integer
end

require 'tty-table'

module AppLogsHelper
  def print_table
    # Initialize the table with headers
    table = TTY::Table.new(header: ['level', 'method', 'path', 'ip_address'])

    # Add the data from your 'AppLog' model
    AppLog.all.each do |row|
      table << [row[:level], row[:method], row[:path], row[:ip_address]]
    end

    # Render the table
    puts table.render(:ascii)
  end
end
