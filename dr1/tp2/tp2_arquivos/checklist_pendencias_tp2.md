# Checklist de Pendencias - TP2 (Tang Nano 9K)

Use esta lista para fechar tudo que ainda depende de voce no Gowin/relatorio.

## 1) Arquivos tecnicos (ja prontos)

- [x] `top.v`
- [x] `logic_block.v`
- [x] `top_tb.v`
- [x] `constraints.cst` (ajustado para Tang Nano 9K)
- [x] `relatorio_tecnico_tp2.md`
- [x] `guia_gowin_click_a_clique.md`

## 2) O que eu nao consigo executar por voce neste ambiente

- [ ] Criar/abrir projeto no Gowin GUI na sua maquina
- [ ] Rodar simulacao na ferramenta escolhida (DSim ou ModelSim)
- [ ] Rodar `Synthesize` e `Place & Route` na sua instancia do Gowin
- [ ] Tirar screenshots da simulacao e dos logs de build
- [ ] Programar FPGA via `Download to SRAM` (se tiver hardware)
- [ ] Capturar fotos/video da placa funcionando (se tiver hardware)

## 3) Passos obrigatorios no Gowin (seu lado)

- [ ] Criar projeto `tp2_tang_nano_9k`
- [ ] Selecionar device `GW1NR-LV9QN88PC6/I5`
- [ ] Adicionar `top.v`, `logic_block.v`, `top_tb.v`, `constraints.cst`
- [ ] Definir `top.v` como top module (`Top`)
- [ ] Executar simulacao com `Top_tb`
- [ ] Confirmar os 6 casos de entrada do enunciado
- [ ] Executar `Synthesize`
- [ ] Executar `Place & Route`
- [ ] Abrir relatórios de sintese/PnR e salvar evidencias

## 4) Pendencias do relatorio

- [ ] Preencher seu nome em `relatorio_tecnico_tp2.md` (`Aluno: _preencher_nome_completo_`)
- [ ] Inserir imagem da waveform da simulacao
- [ ] Inserir evidencia de sintese concluida
- [ ] Inserir evidencia de place & route concluido
- [ ] Se houver hardware: inserir evidencia fisica (foto/video)
- [ ] Concluir texto final comparando esperado x observado

## 5) Empacotamento/entrega

- [ ] Garantir que o ZIP contenha projeto Gowin completo + fontes + relatorio + evidencias
- [ ] Nomear arquivo final no padrao pedido pelo professor
- [ ] Conferir se o professor quer `.zip` somente, ou `.pdf` + `.zip` (o enunciado ficou ambiguo)
