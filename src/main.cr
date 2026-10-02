# Sistema de controle de estoque e vendas
require "./terminal"
require "./inventory"

menu_selected = 0
menu_items = ["Cadastrar produto", "Listar produtos", "Registrar entrada", "Sair"]
products = [] of Product

at_exit { print SHOW_CURSOR }
Signal::INT.trap { exit }

loop do
  # 1. Desenhar a tela baseado no estado atual
  print HIDE_CURSOR
  print CLEAR_SCREEN
  puts "Controle de Estoque e Vendas".colorize.bold
  puts "(j/k: mover, Enter: selecionar, q: sair)\n\n"

  menu_items.each_with_index do |item, index|
    if index == menu_selected
      puts "> #{item}".colorize(:green)
    else
      puts "  #{item}"
    end
  end

  # 2. Ler o input
  case read_key
  when 'j'
    menu_selected = (menu_selected + 1) % menu_items.size
  when 'k'
    menu_selected = (menu_selected - 1) % menu_items.size
  when 'q', '\u{3}'
    break
  when '\r', '\n'
    # 3. Executar a ação selecionada
    print CLEAR_SCREEN
    print SHOW_CURSOR
    case menu_items[menu_selected]
    when "Cadastrar produto"
      name = prompt("Nome: ")
      price = prompt_float("Preço unitário: ")
      quantity = prompt_int("Quantidade inicial: ")
      print_result(register_product(products, name, price, quantity))
    when "Listar produtos"
      puts "%-7s %-20s %9s %8s" % {"Código", "Nome", "Preço", "Saldo"}
      products.each do |product|
        line = "%-7d %-20s %9.2f %8d" % {product.code, product.name, product.price, product.quantity}
        if product.quantity <= LOW_STOCK
          puts line.colorize(:red)
        else
          puts line
        end
      end
      puts "\nNenhum produto cadastrado." if products.empty?
    when "Registrar entrada"
      code = prompt_int("Código do produto: ")
      quantity = prompt_int("Quantidade recebida: ")
      print_result(register_entry(products, code, quantity))
    when "Sair"
      break
    end
    wait_for_key
  end
end
