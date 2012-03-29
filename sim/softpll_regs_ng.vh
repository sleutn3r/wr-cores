`define ADDR_SPLL_CSR                  7'h0
`define SPLL_CSR_PER_SEL_OFFSET 0
`define SPLL_CSR_PER_SEL 32'h0000003f
`define SPLL_CSR_N_REF_OFFSET 8
`define SPLL_CSR_N_REF 32'h00003f00
`define SPLL_CSR_N_OUT_OFFSET 16
`define SPLL_CSR_N_OUT 32'h00070000
`define SPLL_CSR_PER_EN_OFFSET 19
`define SPLL_CSR_PER_EN 32'h00080000
`define ADDR_SPLL_DCCR                 7'h4
`define SPLL_DCCR_GATE_DIV_OFFSET 0
`define SPLL_DCCR_GATE_DIV 32'h0000003f
`define ADDR_SPLL_RCGER                7'h8
`define SPLL_RCGER_GATE_SEL_OFFSET 0
`define SPLL_RCGER_GATE_SEL 32'hffffffff
`define ADDR_SPLL_OCCR                 7'hc
`define SPLL_OCCR_OUT_EN_OFFSET 0
`define SPLL_OCCR_OUT_EN 32'h000000ff
`define SPLL_OCCR_OUT_LOCK_OFFSET 8
`define SPLL_OCCR_OUT_LOCK 32'h0000ff00
`define ADDR_SPLL_RCER                 7'h10
`define ADDR_SPLL_OCER                 7'h14
`define ADDR_SPLL_PER_HPLL             7'h18
`define SPLL_PER_HPLL_ERROR_OFFSET 0
`define SPLL_PER_HPLL_ERROR 32'h0000ffff
`define SPLL_PER_HPLL_VALID_OFFSET 16
`define SPLL_PER_HPLL_VALID 32'h00010000
`define ADDR_SPLL_DAC_HPLL             7'h1c
`define ADDR_SPLL_DAC_MAIN             7'h20
`define SPLL_DAC_MAIN_VALUE_OFFSET 0
`define SPLL_DAC_MAIN_VALUE 32'h0000ffff
`define SPLL_DAC_MAIN_DAC_SEL_OFFSET 16
`define SPLL_DAC_MAIN_DAC_SEL 32'h000f0000
`define ADDR_SPLL_DEGLITCH_THR         7'h24
`define ADDR_SPLL_DFR_SPLL             7'h28
`define SPLL_DFR_SPLL_VALUE_OFFSET 0
`define SPLL_DFR_SPLL_VALUE 32'h7fffffff
`define SPLL_DFR_SPLL_EOS_OFFSET 31
`define SPLL_DFR_SPLL_EOS 32'h80000000
`define ADDR_SPLL_EIC_IDR              7'h40
`define SPLL_EIC_IDR_TAG_OFFSET 0
`define SPLL_EIC_IDR_TAG 32'h00000001
`define ADDR_SPLL_EIC_IER              7'h44
`define SPLL_EIC_IER_TAG_OFFSET 0
`define SPLL_EIC_IER_TAG 32'h00000001
`define ADDR_SPLL_EIC_IMR              7'h48
`define SPLL_EIC_IMR_TAG_OFFSET 0
`define SPLL_EIC_IMR_TAG 32'h00000001
`define ADDR_SPLL_EIC_ISR              7'h4c
`define SPLL_EIC_ISR_TAG_OFFSET 0
`define SPLL_EIC_ISR_TAG 32'h00000001
`define ADDR_SPLL_DFR_HOST_R0          7'h50
`define SPLL_DFR_HOST_R0_VALUE_OFFSET 0
`define SPLL_DFR_HOST_R0_VALUE 32'hffffffff
`define ADDR_SPLL_DFR_HOST_R1          7'h54
`define SPLL_DFR_HOST_R1_SEQ_ID_OFFSET 0
`define SPLL_DFR_HOST_R1_SEQ_ID 32'h0000ffff
`define ADDR_SPLL_DFR_HOST_CSR         7'h58
`define SPLL_DFR_HOST_CSR_FULL_OFFSET 16
`define SPLL_DFR_HOST_CSR_FULL 32'h00010000
`define SPLL_DFR_HOST_CSR_EMPTY_OFFSET 17
`define SPLL_DFR_HOST_CSR_EMPTY 32'h00020000
`define SPLL_DFR_HOST_CSR_USEDW_OFFSET 0
`define SPLL_DFR_HOST_CSR_USEDW 32'h00001fff
`define ADDR_SPLL_TRR_R0               7'h5c
`define SPLL_TRR_R0_VALUE_OFFSET 0
`define SPLL_TRR_R0_VALUE 32'h00ffffff
`define SPLL_TRR_R0_CHAN_ID_OFFSET 24
`define SPLL_TRR_R0_CHAN_ID 32'h7f000000
`define SPLL_TRR_R0_DISC_OFFSET 31
`define SPLL_TRR_R0_DISC 32'h80000000
`define ADDR_SPLL_TRR_CSR              7'h60
`define SPLL_TRR_CSR_EMPTY_OFFSET 17
`define SPLL_TRR_CSR_EMPTY 32'h00020000
