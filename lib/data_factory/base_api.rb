module DataFactory

  # This module is included into the DataFactory::Base class providing methods
  # to generate data and insert it into the database.
  #
  # For most use cases, these methods will not need to be called. The
  # DataFactory::BaseFactory module provides factory methods that create objects and insert
  # the data into database

  module BaseAPI

    include Random

    attr_reader :column_values, :insert_statement, :binds

    def initialize
      unless self.class.meta_data_loaded
        self.class.load_meta_data
      end
      @column_values = Hash.new
    end

    # Retrieves the table name this class interfaces with on the database
    def table_name
      self.class.table_name
    end

    def column_details # :nodoc:
      self.class.column_details
    end

    def column_defaults # :nodoc:
      self.class.column_defaults
    end

    def column_detail(key) # :nodoc:
      self.class.column_detail(key)
    end

    # Retrieves the default value set for a column, which can be a proc
    # or any Ruby object in general, but in practice is likely to be a
    # Date, Time, String, Float, Integer
    def column_default(key)
      self.class.column_default(key)
    end

    # Returns the value assigned to a column, or nil if it is not defined
    def column_value(key)
      # ensure the requested column is in the table
      column_detail(key)
      @column_values[key.to_s.upcase]
    end

    # Returns the database interface object
    def db_interface
      self.class.database_interface
    end

    # Commit changes to the database
    def commit
      db_interface.commit
    end

    # Generates values for all the columns in the table.
    #
    # If no value is passed into this procedure for a column, a default will be used
    # if it is configured. Otherwise a random value will be generated.
    #
    # Values for a column can be passed into this method using a hash, eg:
    #
    #    obj.generate_column_data(:emp_id => 1, :last_name => 'Smith)
    def generate_column_data(params=Hash.new)
      self.class.column_details.keys.each do |k|
        if column_default(k)
          if column_default(k).is_a?(Proc)
            @column_values[k] = column_default(k).call
          else
            @column_values[k] = column_default(k)
          end
        else
          @column_values[k] = generate_value(column_detail(k))
        end
      end
      normalised_params = internalize_column_params(params)
      validate_columns(normalised_params)
      @column_values.merge! normalised_params
    end


    # Generates an insert statement for the current state of the object. It is intended
    # to be called after generate_column_data has been called, otherwise all the values
    # will be null.
    #
    # The generated statement returned as a string and also stored in the @insert_statement
    # instance variable.
    #
    # The insert statement will contain bind variables for all columns. The generated bind
    # variabled are stored in @binds.
    def generate_insert
      @binds = Array.new
      @insert_statement = "insert into #{table_name} ("
      @insert_statement << column_details.keys.sort.map { |k| column_detail(k).column_name }.join(',')
      @insert_statement << ') values ('
      @insert_statement << column_details.keys.sort.map { |k|
        ":#{k}"
      }.join(',')
      column_details.keys.sort.each { |k|
        if @column_values[k] == nil
          @binds.push [column_type_to_ruby_type(column_details[k]), nil]
        else
          @binds.push @column_values[k]
        end
      }
      @insert_statement << ')'
      @insert_statement
    end

    # Runs the insert statement prepared by generate_insert, using the insert
    # statement stored in @insert_statement and the bind variables in @binds
    #
    # If generate_insert has not be executed, this procedure will raise
    # a DataFactory::NoInsertStatement exeception
    def run_insert
      raise DataFactory::NoInsertStatement unless @insert_statement

      stmt = db_interface.execute_sql(@insert_statement, *@binds)
      stmt.close
    end

    # Generates a where clause for the DataFactory object. This method looks at the columns
    # on the table, and the values set against them, and generates a string representing a
    # where clause that can be used in an SQL query.
    #
    # The generated string does not contain the 'where' keyword.
    def where_clause_for(cols)
      cols.map{|c| c.to_s.upcase}.map{|c|
        if @column_values[c] == nil
          "#{c} is null"
        else
          "#{c} = #{quote_value(c) }"
        end
      }.join " and "
    end

    private

    # TODO - This needs to be extracted into a DB specific access layer, as it is
    # Oracle specific.
    def quote_value(col)
      case column_detail(col).data_type
      when 'CHAR', 'VARCHAR2', 'CLOB', 'RAW'
        "'#{@column_values[col]}'"
      when 'DATE', 'DATETIME'
        "to_date('#{@column_values[col].strftime('%Y%m%d %H:%M:%S')}', 'YYYYMMDD HH24:MI:SS')"
      else
        @column_values[col].to_s
      end
    end

    def generate_value(col)
      if col.nullable?
        return nil unless self.class.populate_nullable_columns
      end

      case col.data_type
      when 'CHAR', 'VARCHAR2', 'CLOB'
        random_string_upto_length(col.data_length)
      when 'RAW'
        random_hex_string_upto_length(col.data_length)
      when 'DATE', 'DATETIME', 'TIMESTAMP'
        Time.now
      when 'NUMBER', 'INTEGER'
        scale = 2
        if col.data_scale && col.data_scale == 0
          random_integer(9999)
        else
          22.23
        end

      #   # random numbers is very much beta and very untested.
      #   #
      #   # 38 digits total, 28 before decimal point, and 10 after.
      #   precision = 38
      #   scale     = 10
      #   if col.data_precision
      #     precision = col.data_precision
      #   end
      #   if col.data_scale
      #     scale = col.data_scale
      #   end

      #   if scale == 0
      #     # its an integer
      #     random_integer(10**col.data_precision - 1)
      #   else
      #     # its a number
      #     max_left  = 10**(precision - scale) - 1
      #     max_right = 10**scale - 1
      #     "#{random_integer(max_left)}.#{random_integer(max_right)}".to_f
      #   end
      when 'NUMBER'
        23.34
      when 'INTEGER'
      else
        nil
      end
    end

    def column_type_to_ruby_type(col)
      case col.data_type
      when 'CHAR', 'VARCHAR2', 'CLOB', 'RAW'
        String
      when 'DATE', 'DATETIME', 'TIMESTAMP'
        Time
      when 'INTEGER'
        Integer
      when 'NUMBER'
        if col.data_scale == 0
          Integer
        else
          Float
        end
      else
        raise "unsupported datatype #{col.data_type}"
      end
    end

    def internalize_column_params(params)
      upcased_params = Hash.new
      params.keys.each do |k|
        # change it from a symbol(if it is a symbol) to a string and uppercase.
        upcased_params[k.to_s.upcase] = params[k]
      end
      upcased_params
    end

    def validate_columns(params)
      params.keys.each do |k|
        unless column_details.has_key? k.upcase
          raise DataFactory::ColumnNotInTable, "Column #{k.upcase} is not in #{table_name}"
        end
      end
    end


  end
end
