# Sistema de controle de estoque e vendas
require "./terminal"

menu_selected = 0
menu_items = ["Sair"]

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
    when "Sair"
      break
    end
    wait_for_key
  end
end
