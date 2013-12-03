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
        ['col2', 'varchar2', 20, nil, nil, 2, 'N'],
        ['col3', 'number',   20, 9,   2,   3, 'Y'],
        ['col4', 'number',   20, 9,   2,   4, 'N'],
        ['col5', 'integer',  20, 38,  0,   5, 'Y'],
        ['col6', 'integer',  20, 38,  0,   6, 'N'],
        ['col7', 'DATE',     20, nil, nil, 7, 'Y'],
        ['col8', 'DATE',     20, nil, nil, 8, 'N'],
        ['col9', 'TIMESTAMP',20, nil, nil, 9, 'Y'],
        ['col10','TIMESTAMP',20, nil, nil, 10,'N'],
        ['col11','raw',      20, nil, nil, 11,'Y'],
        ['col12','raw',      20, nil, nil, 12,'N'],
        ['col13','char',     20, nil, nil, 13,'Y'],
        ['col14','char',     20, nil, nil, 14,'N'],
        ['col15','number',   20, 1,   0,   15,'N'],
        ['col16','integer',  20, 4,   9,   16,'N']
      ]
      data.each do |d|
        yield d
      end
    end

    def close
    end
  end

end
