LOW_STOCK = 5

# Classe (e não struct) para que alterar a quantidade altere o produto guardado no array.
class Product
  property code : Int32
  property name : String
  property price : Float64
  property quantity : Int32

  def initialize(@code, @name, @price, @quantity)
  end
end

# Retorna uma mensagem de erro, ou nil quando a operação é realizada.
def register_product(products : Array(Product), name : String, price : Float64, quantity : Int32) : String?
  return "O nome não pode ser vazio." if name.empty?
  return "O preço deve ser maior que zero." if price <= 0
  return "A quantidade não pode ser negativa." if quantity < 0

  next_code = 1
  products.each do |product|
    next_code = product.code + 1 if product.code >= next_code
  end

  products << Product.new(next_code, name, price, quantity)
  nil
end

def find_product(products : Array(Product), code : Int32) : Product?
  products.each do |product|
    return product if product.code == code
  end
  nil
end

def register_entry(products : Array(Product), code : Int32, quantity : Int32) : String?
  product = find_product(products, code)
  return "Produto não encontrado." unless product
  return "A quantidade deve ser maior que zero." if quantity <= 0

  product.quantity += quantity
  nil
end
