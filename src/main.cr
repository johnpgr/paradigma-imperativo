# Projeto: Sistema de controle de estoque e vendas
#
# entidades: Produto, Saldo, Venda
# transformations:
#   - saida, entrada, cadastro
# actions:
#   - consulta de saldo, calculo do valor das vendas

require "colorize"

HIDE_CURSOR = "\e[?25l"
SHOW_CURSOR = "\e[?25h"
CLEAR_SCREEN = "\e[2J\e[H"

selected = 0
items = ["Adicionar", "Listar", "Remover", "Sair"]

def render(items : Array(String), selected : Int32)
  print CLEAR_SCREEN

  items.each_with_index do |item, index|
    if index == selected
      print "> #{item}".colorize(:green)
    else
      print "  #{item}"
    end

    print "\r\n"
  end
end

print HIDE_CURSOR

begin
  STDIN.raw do
    loop do
      render(items, selected)

      key = STDIN.read_char

      case key
      when 'j'
        selected = (selected + 1) % items.size
      when 'k'
        selected = (selected - 1) % items.size
      when 'q'
        break
      end

      # ler input
      # atualizar selected
      # executar acao
    end
  end
ensure
  print SHOW_CURSOR
end
