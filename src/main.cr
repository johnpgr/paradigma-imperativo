# Sistema de controle de estoque e vendas
require "./terminal"
require "./inventory"

enum MenuAction
  RegisterProduct
  ListProducts
  RegisterEntry
  RegisterSale
  SalesReport
  RemoveProduct
  Exit
end

menu_selected = 0
menu_items = [
  {MenuAction::RegisterProduct, "Cadastrar produto"},
  {MenuAction::ListProducts, "Listar produtos"},
  {MenuAction::RegisterEntry, "Registrar entrada"},
  {MenuAction::RegisterSale, "Registrar venda"},
  {MenuAction::SalesReport, "Relatório de vendas"},
  {MenuAction::RemoveProduct, "Remover produto"},
  {MenuAction::Exit, "Sair"},
]

products = [] of Product
sales = [] of Sale

Process.on_terminate { exit }
at_exit { show_cursor }

loop do
  # 1. Desenhar a tela baseado no estado atual
  hide_cursor
  clear_screen
  puts "Controle de Estoque e Vendas".colorize.bold
  puts "(j/k: mover, Enter: selecionar, q: sair)\n\n"

  menu_items.each_with_index do |item, index|
    if index == menu_selected
      puts "> #{item[1]}".colorize(:green)
    else
      puts "  #{item[1]}"
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
    clear_screen
    show_cursor

    case menu_items[menu_selected][0]

    when MenuAction::RegisterProduct
      name = prompt("Nome: ")
      price = prompt_float("Preço unitário: ")
      quantity = prompt_int("Quantidade inicial: ")
      print_result(register_product(products, name, price, quantity))

    when MenuAction::ListProducts
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

    when MenuAction::RegisterEntry
      code = prompt_int("Código do produto: ")
      quantity = prompt_int("Quantidade recebida: ")
      print_result(register_entry(products, code, quantity))

    when MenuAction::RegisterSale
      code = prompt_int("Código do produto: ")
      quantity = prompt_int("Quantidade vendida: ")
      print_result(register_sale(products, sales, code, quantity))

    when MenuAction::SalesReport
      puts "%-7s %-20s %5s %12s" % {"Código", "Produto", "Qtd.", "Total"}

      sales.each do |sale|
        puts "%-7d %-20s %5d %12.2f" % {sale.code, sale.name, sale.quantity, sale.total}
      end

      items, total = sales_summary(sales)
      puts "\nItens vendidos: #{items}"
      puts "Valor total:    R$ #{"%.2f" % total}".colorize.bold

    when MenuAction::RemoveProduct
      code = prompt_int("Código do produto: ")
      print_result(remove_product(products, code))

    when MenuAction::Exit
      break

    end

    wait_for_key
  end
end
