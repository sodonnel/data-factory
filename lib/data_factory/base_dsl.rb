module DataFactory

  # This module is used to extend the DataFactory::Base class, and so creates a
  # series of class instance methods that can be used in class definitions.
  #
  # For example:
  #
  #    class Foo < DataFactory::Base
  #
  #      set_table_name "Foobar"
  #      set_column_default :last_name, 'Smith'
  #
  #    end
  #
  # For this reason, calling any of these methods on a class, will affect ALL instances
  # of that class.
  #
  # Any subclasses expect the class variables @@db_interface to be set, containing a database
  # access class, eg:
  #
  #     DataFactory::Base.set_database_interface(interface_obj)
  #
  # As this is stored in a class variable the same database interface is shared down the entire
  # inheritance chain. Therefore if many database connections are required, several base classes
  # will need to be created by including the relevant modules, eg:
  #
  #     class OtherBaseClass
  #       extend BaseDSL
  #       extend BaseFactory
  #       include BaseAPI
  #     end

  module BaseDSL

    attr_reader :table_name, :column_details, :column_defaults, :meta_data_loaded, :populate_nullable_columns

    # Pass a database interface object to be used by all DataFactory sub-classes
    # The interface must implement the following two methods:
    #
    #     def execute_sql(statement, *binds)
    #     end
    #
    #     def each_array(&blk)
    #     end
    #
    #     def commit
    #     end
    #
    # This method is normally called on the DataFactory::Base class. It will
    # set a class variable (@@db_interface) in the Base class which is shared
    # by all sub-classes of the class.
    #
    # Ideally use the SimpleOracleJDBC gem to provide the interface
    def set_database_interface(interface)
      class_variable_set("@@db_interface", interface)
    end


    # Returns the database interface that was set by set_database_interface
    def database_interface
      class_variable_get("@@db_interface")
    end


    # Defines the table a subclass of DataFactory interacts with on the database. This
    # method stores the tables in a class instance variable (@table_name) that is shared by
    # all instances of the class, but is not inherited with subclasses.
    def set_table_name(tab)
      @table_name = tab.to_s.upcase
      @populate_nullable_columns = false
    end

    # By default, no values will be generated for columns that can be null. By calling this
    # method in the class defintion, it will set @populate_nullable_columns to true, which will
    # cause values to be generated for nullable columns in the same way as for not null columns
    # @example
    #    class MyTab < DataFactory::Base
    #      set_table_name 'my_table'
    #      populate_nullable_columns
    #    end
    def set_populate_nullable_columns
      @populate_nullable_columns = true
    end

    # Sets the default value to be used for a column if nothing else is
    # specified. The block is optional and should be used if dynamic defaults
    # are required. If the default is a constant, a simple value can be specified.
    # The default is stored within a hash which is stored in a class instance variable
    # (@column_defaults) that is shared by all instances of the class, but is not inherited
    # with subclasses.
    def set_column_default(column_name, value=nil, &block)
      unless defined? @column_defaults
        @column_defaults = Hash.new
      end
      @column_defaults[column_name.to_s.upcase] = block_given? ? block :
        value.is_a?(Symbol) ? value.to_s : value
    end


    # Returns the value for a column default. If it is a simple value, the value
    # is returned. If the default is a proc, the proc is executed and the resulting
    # values is returned.
    def column_default(column_name)
      return nil unless defined? @column_defaults

      val = @column_defaults[column_name.to_s.upcase]
      if val.is_a?(Proc)
        val.call
      else
        val
      end
    end


    # Returns a DataFactory::Column object that defines the properties
    # of the column
    def column_detail(column_name)
      load_meta_data unless meta_data_loaded

      unless @column_details.has_key?(column_name.to_s.upcase)
        raise DataFactory::ColumnNotInTable, "Column #{column_name.to_s.upcase} is not in #{table_name}"
      end

      @column_details[column_name.to_s.upcase]
    end


    # Used to load the table meta-data from the database
    # TODO - abstract into a database layer as this code is Oracle specific
    def load_meta_data # :nodoc:
      raise DataFactory::TableNotSet unless @table_name
      raise DataFactory::DatabaseInterfaceNotSet unless class_variable_defined?("@@db_interface")

      if meta_data_loaded
        return
      end

      @column_details  = Hash.new

      unless defined? @column_defaults
        @column_defaults = Hash.new
      end

      table_details_sql = "select column_name,
                                  data_type,
                                  nvl(char_length, data_length),
                                  data_precision,
                                  data_scale,
                                  column_id,
                                  nullable
                           from user_tab_columns
                           where table_name = ?
                           order by column_id asc"

      database_interface.execute_sql(table_details_sql, @table_name).each_array do |r|
        c = Column.new
        c.column_name     = r[0].upcase
        c.data_type       = r[1].upcase
        c.data_length     = r[2].to_i
        c.data_precision  = r[3].to_i
        c.data_scale      = r[4].to_i
        c.position        = r[5].to_i
        c.nullable        = r[6] == 'N' ? false : true
        @column_details[r[0].upcase] = c
      end
      @meta_data_loaded = true
      # This is needed here as some column defaults will have been set
      # before the meta_data was loaded and hence will not have been checked
      validate_column_defaults
    end

    private

    def validate_column_defaults
      @column_defaults.keys.each do |k|
        validate_column_default(k, @column_defaults[k])
      end
    end


    def validate_column_default(column_name, column_value)
      unless @column_details.has_key? column_name
        raise DataFactory::ColumnNotInTable, "Column #{column_name.to_s.upcase} is not in #{table_name}"
      end
    end

  end
end
