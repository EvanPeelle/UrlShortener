##############################################
## Helpers  -- metaid.rb (courtesy of _why) ##
##############################################

class Object
    # The hidden singleton lurks behind everyone
    def metaclass
        class << self 
            self
        end
    end

    def meta_eval(&blk)
        metaclass.instance_eval(&blk)
    end

    # Adds methods to a metaclass
    def meta_def(name, &blk)
        meta_eval { define_method name, &blk }
    end
end

###############################################


### Classes store methods, not Objects

class Person
  def initialize(name)
    @name = name
  end

  # forgot to include accessor for name
end

jon = Person.new("Jon")

# Object 'jon' cannot find 'name' method
jon.name;  
# => NoMethod...

# reopen class and add name accessor
class Person
  def name
    @name
  end
end

# already instantiated Object 'jon'
# has dynamically aquired a 'name' method.
#
# This works because methods are contained
# in classes, and Ruby uses dynamic method 
# invocation
#
# i.e. the Ruby interpreter looks up the 
# inheritance chain at runtime only in the 
# instant a method is invoked.

jon.name;  
# => Jon

##########################################

motto = "Eat green vegetables"

slogan = "We love Metaprogramming and so can you!"

# Explicit receiver in method definition
def motto.slice(*args)
  "How dare you!! Our motto is way better than --#{super}--"
end

motto.slice(0..2)
# => "How dare you!! Our motto is way better than --Eat--"

slogan.slice(0..6)
# => "We love"

# every class method is stored in a metaclass
class Chef

    # Read only access to attribute
    attr_reader :name 

    # Read and write access to attribute
    attr_accessor :experience

    def initialize(name, experience)
        @name = name
        @experience = experience
    end

    # class method that defines the
    # 'specialty' method on the meta
    # class of 'self'.
    #
    # unwrapping method calls:
    #
    # metaclass.instance_eval(do 
    #   define_method(:specialty, do
    #       "I am a #{craft}!!"
    #     end) 
    #   end)
    def self.specialize(craft)
      meta_def :specialty, do 
        "I am a #{craft}!!"
      end 
    end

    # setter method for name atttribute
    def name=(name)
      @name = name
    end
end

# Baker class that inherits from Chef
class Baker < Chef

    # method not added to the Chef metaclass, 
    # but to the derived class Baker.
    #
    # this is a method call that dynamically
    # defines a method call 'specialty' on
    # Baker as a class method.
    specialize "Swift Baker"
end 

# Icer class that inherits from Chef
class Icer < Chef
    specialize "Rad Icer"
end 

########################################

Baker.specialty
# => "I am a Swift Baker"

Icer.specialty
# => "I am a Rad Icer"

jon = Baker.new("Jon", 13)

jon.specialty
# => NoMethod...