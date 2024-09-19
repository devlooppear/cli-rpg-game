#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHTGREEN='\033[1;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

declare -A personagem

declare -A inimigo

fase=1
habilidades=()
max_habilidades=2
especial_count=0
nivel=1
experiencia=0
experiencia_para_proximo_nivel=100

declare -A habilidades_personagem=(
    ["Guerreiro"]="Corte-Poderoso,Bloqueio"
    ["Mago"]="Bola-de-Fogo,Escudo-Mágico"
    ["Arqueiro"]="Tiro-Preciso,Evasão"
)

declare -A vida_maxima
vida_maxima["Guerreiro"]=550
vida_maxima["Mago"]=520
vida_maxima["Arqueiro"]=630

function select_character() {
    clear
    echo -e "${CYAN}${BOLD}==========================================="
    echo -e "        Bem-vindo ao O Último Guardião RPG!"
    echo -e "===========================================${RESET}"

    echo -e "${LIGHTGREEN}Escolha seu personagem:${RESET}"
    echo -e "${BLUE}1: Guerreiro 🗡️${RESET}"
    echo -e "${PURPLE}2: Mago 🔮${RESET}"
    echo -e "${GREEN}3: Arqueiro 🏹${RESET}"

    read -r escolha

    case $escolha in
    1)
        personagem['nome']="Guerreiro"
        personagem['emoji']="🗡️"
        ;;
    2)
        personagem['nome']="Mago"
        personagem['emoji']="🔮"
        ;;
    3)
        personagem['nome']="Arqueiro"
        personagem['emoji']="🏹"
        ;;
    *)
        echo -e "${RED}Opção inválida! Usando Guerreiro como padrão.${RESET}"
        personagem['nome']="Guerreiro"
        personagem['emoji']="🗡️"
        ;;
    esac

    personagem['vida']=${vida_maxima[${personagem['nome']}]}
    personagem['vida_maxima']=${vida_maxima[${personagem['nome']}]}
    personagem['ataque']=30
    personagem['defesa']=20
}

function show_status() {
    echo -e "${personagem['emoji']} ${personagem['nome']}: Vida ${personagem['vida']}, Ataque ${personagem['ataque']}, Defesa ${personagem['defesa']}, Nível ${nivel}, Experiência ${experiencia}/${experiencia_para_proximo_nivel}"
    echo "Ataques Especiais: $especial_count/${max_habilidades}"
    show_life_bar
}

function show_life_bar() {
    show_current_life=${personagem['vida']}
    vida_maxima=${personagem['vida_maxima']}
    porcentagem=$((show_current_life * 100 / vida_maxima))
    largura_barra=50
    tamanho_ocupado=$((largura_barra * porcentagem / 100))
    barra=$(printf "%-${tamanho_ocupado}s" "+" | tr ' ' '+')
    barra=$(printf "%-${largura_barra}s" "$barra")
    echo -e "Vida: [${GREEN}${barra}${RESET}] ${show_current_life}/${vida_maxima} (${porcentagem}%)"
}

function show_status_enemy() {
    echo -e "\n🛡️ ${inimigo['emoji']} ${inimigo['nome']}: Vida ${inimigo['vida']}, Ataque ${inimigo['ataque']}, Defesa ${inimigo['defesa']}"
}

function use_ability() {
    habilidade=$1
    if [[ ! " ${habilidades[@]} " =~ " ${habilidade} " ]]; then
        echo "Você não possui a habilidade ${habilidade}!"
        return
    fi

    case $habilidade in
    "Corte-Poderoso")
        dano=$(((personagem['ataque'] * 2) - inimigo['defesa']))
        [ $dano -lt 0 ] && dano=0
        echo "Você usou Corte Poderoso e causou ${dano} de dano!"
        inimigo['vida']=$((inimigo['vida'] - dano))
        ;;
    "Bloqueio")
        personagem['defesa']=$((personagem['defesa'] + 1))
        echo "Sua defesa aumentou em 1 ponto!"
        ;;
    "Bola-de-Fogo")
        dano=40
        echo "Você usou Bola de Fogo e causou ${dano} de dano!"
        inimigo['vida']=$((inimigo['vida'] - dano))
        ;;
    "Escudo-Mágico")
        personagem['defesa']=$((personagem['defesa'] + 2))
        echo "Sua defesa aumentou em 2 pontos!"
        ;;
    "Tiro-Preciso")
        dano=$(((personagem['ataque'] - inimigo['defesa'] + 10)))
        [ $dano -lt 0 ] && dano=0
        echo "Você usou Tiro Preciso e causou ${dano} de dano!"
        inimigo['vida']=$((inimigo['vida'] - dano))
        ;;
    "Evasão")
        personagem['defesa']=$((personagem['defesa'] + 2))
        echo "Sua defesa aumentou em 2 pontos!"
        ;;
    esac

    especial_count=$((especial_count + 1))
}

function random_event() {
    eventos=("Achou uma poção" "Achou uma espada")
    evento=${eventos[RANDOM % ${#eventos[@]}]}
    echo "$evento. Usar?"
    echo "1: Sim"
    echo "2: Não"
    read -r escolha

    if [ "$escolha" == "1" ]; then
        efeito=$((RANDOM % 2))
        case $evento in
        "Achou uma poção")
            personagem['vida']=$((personagem['vida'] + 10))
            [ ${personagem['vida']} -gt ${personagem['vida_maxima']} ] && personagem['vida']=${personagem['vida_maxima']}
            echo "Vida aumentada."
            ;;
        "Achou uma espada")
            if [ $efeito -eq 0 ]; then
                personagem['ataque']=$((personagem['ataque'] + 5))
                echo "Ataque aumentado."
            else
                personagem['ataque']=$((personagem['ataque'] - 5))
                echo "Ataque diminuído."
            fi
            ;;
        esac
    fi
}

function misadventure() {
    inimigos=("Dragão" "Lobo" "Bruxo" "Orc" "Fantasma")
    emojis=("🐉" "🐺" "🧙" "👹" "👻")
    idx=$((RANDOM % ${#inimigos[@]}))
    inimigo['nome']=${inimigos[$idx]}
    inimigo['emoji']=${emojis[$idx]}

    inimigo['vida']=38
    inimigo['ataque']=40
    inimigo['defesa']=20

    if ((fase % 10 == 0)); then
        echo -e "\n⚔️ Você encontrou um CHEFE: ${inimigo['emoji']} ${inimigo['nome']} com poder aumentado!"        
        aumento=0.001
        inimigo['vida']=$(printf "%.0f" $(echo "${inimigo['vida']} * (13 / 10) * (1 + $aumento)" | bc))
        inimigo['ataque']=$(printf "%.0f" $(echo "${inimigo['ataque']} * (13 / 10) * (1 + $aumento)" | bc))
        inimigo['defesa']=$(printf "%.0f" $(echo "${inimigo['defesa']} * (13 / 10) * (1 + $aumento)" | bc))
    fi
    
    if ((fase % 2 == 0)); then
        random_event
    fi

    echo -e "\n🔵 Fase $fase - Você encontrou ${inimigo['emoji']} ${inimigo['nome']}!"
    show_status
    show_status_enemy

    while [ ${personagem['vida']} -gt 0 ] && [ ${inimigo['vida']} -gt 0 ]; do
        echo -e "\nO que você vai fazer?"
        echo "1: Atacar"
        echo "2: Fugir"

        habilidades=($(echo ${habilidades_personagem[${personagem['nome']}]//,/ }))

        for i in "${!habilidades[@]}"; do
            echo "$((i + 3)): ${habilidades[$i]}"
        done
        
        echo -e "${RED}S: Sair${RESET}"
        echo -e "${BLUE}R: Recomeçar${RESET}"

        read -r acao

        case $acao in
        1)
            dano=$((personagem['ataque'] - inimigo['defesa']))
            [ $dano -lt 0 ] && dano=0
            echo -e "${personagem['emoji']} Você atacou e causou ${dano} de dano!"
            inimigo['vida']=$((inimigo['vida'] - dano))
            ;;
        2)
            chance_fuga=$((RANDOM % 2))
            if [ $chance_fuga -eq 1 ]; then
                echo "Você fugiu com sucesso!"
                return
            else
                echo "Você falhou ao tentar fugir!"
            fi
            ;;
        "S" | "s")
            echo -e "${RED}Você escolheu sair do jogo. Até logo!${RESET}"
            exit 0
            ;;
        "R" | "r")
            echo -e "${BLUE}Recomeçando o jogo...${RESET}"
            fase=1
            select_character
            return
            ;;
        *)
            habilidade=${habilidades[$((acao - 3))]}
            use_ability "$habilidade"
            ;;
        esac

        dano_inimigo=$((inimigo['ataque'] - personagem['defesa']))
        [ $dano_inimigo -lt 0 ] && dano_inimigo=0
        personagem['vida']=$((personagem['vida'] - dano_inimigo))
        echo -e "${inimigo['emoji']} O inimigo atacou e causou ${dano_inimigo} de dano!"
        show_status
        show_status_enemy
    done

    if [ ${personagem['vida']} -le 0 ]; then
        echo -e "${RED}Você foi derrotado...${RESET}"
    else
        echo -e "${GREEN}Você venceu ${inimigo['nome']}!${RESET}"
        experiencia=$((experiencia + 50))
        if [ $experiencia -ge $experiencia_para_proximo_nivel ]; then
            nivel=$((nivel + 1))
            experiencia=$((experiencia - experiencia_para_proximo_nivel))
            experiencia_para_proximo_nivel=$((experiencia_para_proximo_nivel * 2))
            echo -e "${GREEN}Você subiu para o nível ${nivel}!${RESET}"
        fi
    fi

    fase=$((fase + 1))
}

function play() {
    select_character
    while true; do
        misadventure
        if [ ${personagem['vida']} -le 0 ]; then
            echo "Game Over!"
            break
        fi
    done
}


play
