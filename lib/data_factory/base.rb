module DataFactory

  # The Base class provides a class designed to be sub-classed. It does not create any
  # methods on its own, but is extended with class methods from the BaseDSL and BaseFactory
  # modules and has the BaseAPI module included to provide instance methods.

  class Base

    extend BaseDSL
    extend BaseFactory

    include BaseAPI

  end

end
