# DataFactory

DataFactory is a simple Ruby gem that generates data random test data and inserts it into database tables. It was created to help with unit testing in a project that had database tables having many (50+) columns, and manually crafing insert statements was tedious and error prone.

DataFactory reads the table definition from the database, and generates random values for all not null columns. It inserts this data into the table, while providing the option of specifying non-random defaults.

In the 0.1 release DataFactory can be considered beta software. In other words it is not really production ready, but then as it generates random test data, it is not really designed to run on a production system, so that is probably OK. It is also missing many potential features, and could easily be enhanced to do much more.

# Database Compatibility

Right now, DataFactory only works with Oracle databases. It should be fairly easy to extend it to other databases, but all the DB interactions have not been abstracted into an access layer, so there would be some work to do.

# Requirements

There are no strict dependencies for DataFactory to work, and it is a pure Ruby gem.

However, DataFactory doesn't actually have a database access layer built in, as it is designed to use an external access layer that knows how to connect and query the database. 

If you can use JRuby, consider using Simple JDBC Oracle to interact with your database. If you cannot use JRuby, implementing your own database interface is simple. Create a class that handles creating a database connection, and implement the following three methods to run SQL statements on the database, and issue commits:

    # should return an object that implements the each_array method
    # below
    def execute_sql(statement, *binds)
    end

    def commit
    end

    def each_array(&blk)
    end

The first two methods are fairly obvious. The each_array method is expected to iterate over the result set returned by the executed sql statement, passing an array of columns to the block for each row returned. The array should contain the value of each column in Ruby types, ie not Java types if using JRuby.

The OCI8 gem is pretty good place to start if you are using MRI Ruby, but you will need the Oracle client installed. Raw JDBC can get the job done if you are using JRuby and you do not want to use Simple JDBC Oracle.

# Usage

DataFactory is a simple gem, so a few examples explore a lot of the functionality. Note that these examples use Simple Oracle JDBC as the database access layer. 

For these examples to run, create a table on the database as follows:

    create table employees (emp_id     integer,
                            dept_id    integer,
                            first_name varchar2(50),
                            last_name  varchar2(50),
                            email      varchar2(50),
                            ssn        varchar2(10));

## Define a DataFactory Class

To use DataFactory, create a class for each table you want to interface with, and make it a sub-class of DataFactory::Base:

    class Employee < DataFactory::Base
    
      set_table_name "employees"
    
      set_column_default :last_name, "Smith"
      set_column_default :email,   begin    
                                     "#{rand(10000)}@#{rand(10000)}.com"
                                   end
    end

In the class definition, use the set_table_name method to map the class to a particular table on the database.

Optionally, you can specify default values for columns in the table with the set_column_default method, which takes the table name followed by a value for the column, or a block that generates the value each time it is called, as with the email example.


## Creating a Row

The first requirement is to connect to the database, and hand an instance of the database interface to DataFactory:

    interface = SimpleOracleJDBC::Interface.create('sodonnel',
                                                   'sodonnel',
                                                   'local11gr2.world',
                                                   'localhost',
                                                   '1521')
    
    DataFactory::Base.set_database_interface(interface)

Then a row can be created using the create! method, for example:

    f = Employee.create!("emp_id" => 1001)

The create! call will take the column defaults defined in the Employee class, and merge in any column values passed into the create! method. Then it will generate a value for any other non-nullable columns in the table, and insert the row into the database.

An Employee instance is returned, containing all the generated values.

## Putting It Together

Combining each of the steps above, gives the following script:

    require 'rubygems'
    require 'simple_oracle_jdbc'
    require 'data_factory'
    
    class Employee < DataFactory::Base
    
      set_table_name "employees"
    
      set_column_default :last_name, "Smith"
      set_column_default :email,   begin
                                     "#{rand(10000)}@#{rand(10000)}.com"
                                   end
    end
    
    interface = SimpleOracleJDBC::Interface.create('sodonnel',
                                                   'sodonnel',
                                                   'local11gr2.world',
                                                   'localhost',
                                                   '1521')
    
    DataFactory::Base.set_database_interface(interface)

    f = Employee.create!("emp_id" => 1001)
    
    f.column_values.keys.each do |k|
      puts f.column_values[k]
    end

## Other Methods

The sample above illustrates how the create! method returns an Employee object, giving access to the generated values. For an overview of other methods browse the documentation for the base_api, base_dsl and base_factory methods.






  