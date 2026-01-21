

class Service
  private_class_method :new

  def self.call(**kwargs, &block)
    new(**kwargs).call(&block)
  end
end