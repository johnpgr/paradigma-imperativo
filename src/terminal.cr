require "colorize"

HIDE_CURSOR  = "\e[?25l"
SHOW_CURSOR  = "\e[?25h"
CLEAR_SCREEN = "\e[2J\e[H"

# O modo raw é usado só para ler uma tecla; os formulários usam leitura por linha.
def read_key : Char?
  STDIN.raw &.read_char
end

def prompt(label : String) : String
  print label
  (gets || exit).strip
end

def prompt_int(label : String) : Int32
  loop do
    value = prompt(label).to_i?
    return value if value
    puts "Digite um número inteiro.".colorize(:red)
  end
end

def prompt_float(label : String) : Float64
  loop do
    value = prompt(label).to_f?
    return value if value
    puts "Digite um número.".colorize(:red)
  end
end

def wait_for_key
  print "\nPressione qualquer tecla para voltar..."
  read_key
end

def print_result(error : String?)
  if error
    puts error.colorize(:red)
  else
    puts "Operação realizada.".colorize(:green)
  end
end
