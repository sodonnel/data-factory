$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
$:.unshift File.expand_path(File.dirname(__FILE__))

#require 'rubygems'
#require 'simple_oracle_jdbc'
require 'data_factory'
require 'test/unit'
require 'mocha/setup'

module TestHelper

  DB_USER     = 'sodonnel'
  DB_PASSWORD = 'sodonnell'
  DB_SERVICE  = 'local11gr2.world'
  DB_HOST     = 'localhost'
  DB_PORT     = '1521'

#  @@interface ||= SimpleOracleJDBC::Interface.create(DB_USER,
#                                                     DB_PASSWORD,
#                                                     DB_SERVICE,
#                                                     DB_HOST,
#                                                     DB_PORT)

  class DBInterfaceMock
    def execute_sql(sql, binds)
      self
    end

    # Mock out returing a list of columns for a table.
    def each_array(&blk)
      data = [
              # cname, type       len  precision, scale, position, nullable
              ['col1', 'varchar2', 20, nil, nil, 1, 'Y'],
              ['col2', 'number',   20, 9,   2,   2, 'Y'],
              ['col3', 'DATE',     20, nil, nil, 3, 'N'],
              ['col4', 'varchar2', 20, nil, nil, 4, 'N'],
              ['col5', 'integer',  20, 38,  0, 5, 'N'],
              ['col6', 'number',   20, 20,  5, 6, 'N']
             ]
      data.each do |d|
        yield d
      end
    end

    def close
    end
  end

end
