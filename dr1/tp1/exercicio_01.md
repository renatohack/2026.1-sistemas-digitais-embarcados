# Exercício 1

## Tabela comparativa: FPGA x Microcontrolador x ASIC

| Critério | FPGA | Microcontrolador | ASIC |
|---|---|---|---|
| Flexibilidade | Alta: lógica digital customizável em hardware | Média: software flexível, hardware interno fixo | Baixa: função definida no projeto do chip |
| Custo em baixas quantidades | Médio/alto por unidade, sem custo NRE elevado | Baixo por unidade, normalmente mais barato em pequeno volume | Muito alto (alto NRE, máscaras e fabricação) |
| Reconfiguração | Sim, reprogramável em campo várias vezes | Parcial: firmware regravável, mas arquitetura de hardware não muda | Não (na prática, após fabricação) |

## Tecnologia mais adequada para prototipação

A **FPGA** é a mais adequada para prototipação de sistemas digitais, porque combina:
- alta flexibilidade lógica;
- reconfiguração rápida durante testes;
- baixo risco técnico para iterações, sem custo inicial de fabricação de chip.

Em prototipação, essa combinação normalmente é mais importante que o custo unitário.
