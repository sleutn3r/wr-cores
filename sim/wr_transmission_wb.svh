`define ADDR_WR_TRANSMISSION_SSCR1     7'h0
`define WR_TRANSMISSION_SSCR1_RST_STATS_OFFSET 0
`define WR_TRANSMISSION_SSCR1_RST_STATS 32'h00000001
`define WR_TRANSMISSION_SSCR1_RST_SEQ_ID_OFFSET 1
`define WR_TRANSMISSION_SSCR1_RST_SEQ_ID 32'h00000002
`define WR_TRANSMISSION_SSCR1_SNAPSHOT_STATS_OFFSET 2
`define WR_TRANSMISSION_SSCR1_SNAPSHOT_STATS 32'h00000004
`define WR_TRANSMISSION_SSCR1_RX_LATENCY_ACC_OVERFLOW_OFFSET 3
`define WR_TRANSMISSION_SSCR1_RX_LATENCY_ACC_OVERFLOW 32'h00000008
`define WR_TRANSMISSION_SSCR1_RST_TS_CYC_OFFSET 4
`define WR_TRANSMISSION_SSCR1_RST_TS_CYC 32'hfffffff0
`define ADDR_WR_TRANSMISSION_SSCR2     7'h4
`define WR_TRANSMISSION_SSCR2_RST_TS_TAI_LSB_OFFSET 0
`define WR_TRANSMISSION_SSCR2_RST_TS_TAI_LSB 32'hffffffff
`define ADDR_WR_TRANSMISSION_TX_STAT   7'h8
`define WR_TRANSMISSION_TX_STAT_TX_SENT_CNT_OFFSET 0
`define WR_TRANSMISSION_TX_STAT_TX_SENT_CNT 32'hffffffff
`define ADDR_WR_TRANSMISSION_RX_STAT1  7'hc
`define WR_TRANSMISSION_RX_STAT1_RX_RCVD_CNT_OFFSET 0
`define WR_TRANSMISSION_RX_STAT1_RX_RCVD_CNT 32'hffffffff
`define ADDR_WR_TRANSMISSION_RX_STAT2  7'h10
`define WR_TRANSMISSION_RX_STAT2_RX_LOSS_CNT_OFFSET 0
`define WR_TRANSMISSION_RX_STAT2_RX_LOSS_CNT 32'hffffffff
`define ADDR_WR_TRANSMISSION_RX_STAT3  7'h14
`define WR_TRANSMISSION_RX_STAT3_RX_LATENCY_MAX_OFFSET 0
`define WR_TRANSMISSION_RX_STAT3_RX_LATENCY_MAX 32'h0fffffff
`define ADDR_WR_TRANSMISSION_RX_STAT4  7'h18
`define WR_TRANSMISSION_RX_STAT4_RX_LATENCY_MIN_OFFSET 0
`define WR_TRANSMISSION_RX_STAT4_RX_LATENCY_MIN 32'h0fffffff
`define ADDR_WR_TRANSMISSION_RX_STAT5  7'h1c
`define WR_TRANSMISSION_RX_STAT5_RX_LATENCY_ACC_LSB_OFFSET 0
`define WR_TRANSMISSION_RX_STAT5_RX_LATENCY_ACC_LSB 32'hffffffff
`define ADDR_WR_TRANSMISSION_RX_STAT6  7'h20
`define WR_TRANSMISSION_RX_STAT6_RX_LATENCY_ACC_MSB_OFFSET 0
`define WR_TRANSMISSION_RX_STAT6_RX_LATENCY_ACC_MSB 32'hffffffff
`define ADDR_WR_TRANSMISSION_RX_STAT7  7'h24
`define WR_TRANSMISSION_RX_STAT7_RX_LATENCY_ACC_CNT_OFFSET 0
`define WR_TRANSMISSION_RX_STAT7_RX_LATENCY_ACC_CNT 32'hffffffff
`define ADDR_WR_TRANSMISSION_RX_STAT8  7'h28
`define WR_TRANSMISSION_RX_STAT8_RX_LOST_BLOCK_CNT_OFFSET 0
`define WR_TRANSMISSION_RX_STAT8_RX_LOST_BLOCK_CNT 32'hffffffff
`define ADDR_WR_TRANSMISSION_TX_CFG0   7'h2c
`define WR_TRANSMISSION_TX_CFG0_ETHERTYPE_OFFSET 0
`define WR_TRANSMISSION_TX_CFG0_ETHERTYPE 32'h0000ffff
`define ADDR_WR_TRANSMISSION_TX_CFG1   7'h30
`define WR_TRANSMISSION_TX_CFG1_MAC_LOCAL_LSB_OFFSET 0
`define WR_TRANSMISSION_TX_CFG1_MAC_LOCAL_LSB 32'hffffffff
`define ADDR_WR_TRANSMISSION_TX_CFG2   7'h34
`define WR_TRANSMISSION_TX_CFG2_MAC_LOCAL_MSB_OFFSET 0
`define WR_TRANSMISSION_TX_CFG2_MAC_LOCAL_MSB 32'h0000ffff
`define ADDR_WR_TRANSMISSION_TX_CFG3   7'h38
`define WR_TRANSMISSION_TX_CFG3_MAC_TARGET_LSB_OFFSET 0
`define WR_TRANSMISSION_TX_CFG3_MAC_TARGET_LSB 32'hffffffff
`define ADDR_WR_TRANSMISSION_TX_CFG4   7'h3c
`define WR_TRANSMISSION_TX_CFG4_MAC_TARGET_MSB_OFFSET 0
`define WR_TRANSMISSION_TX_CFG4_MAC_TARGET_MSB 32'h0000ffff
`define ADDR_WR_TRANSMISSION_RX_CFG0   7'h40
`define WR_TRANSMISSION_RX_CFG0_ETHERTYPE_OFFSET 0
`define WR_TRANSMISSION_RX_CFG0_ETHERTYPE 32'h0000ffff
`define WR_TRANSMISSION_RX_CFG0_ACCEPT_BROADCAST_OFFSET 16
`define WR_TRANSMISSION_RX_CFG0_ACCEPT_BROADCAST 32'h00010000
`define WR_TRANSMISSION_RX_CFG0_FILTER_REMOTE_OFFSET 17
`define WR_TRANSMISSION_RX_CFG0_FILTER_REMOTE 32'h00020000
`define ADDR_WR_TRANSMISSION_RX_CFG1   7'h44
`define WR_TRANSMISSION_RX_CFG1_MAC_LOCAL_LSB_OFFSET 0
`define WR_TRANSMISSION_RX_CFG1_MAC_LOCAL_LSB 32'hffffffff
`define ADDR_WR_TRANSMISSION_RX_CFG2   7'h48
`define WR_TRANSMISSION_RX_CFG2_MAC_LOCAL_MSB_OFFSET 0
`define WR_TRANSMISSION_RX_CFG2_MAC_LOCAL_MSB 32'h0000ffff
`define ADDR_WR_TRANSMISSION_RX_CFG3   7'h4c
`define WR_TRANSMISSION_RX_CFG3_MAC_REMOTE_LSB_OFFSET 0
`define WR_TRANSMISSION_RX_CFG3_MAC_REMOTE_LSB 32'hffffffff
`define ADDR_WR_TRANSMISSION_RX_CFG4   7'h50
`define WR_TRANSMISSION_RX_CFG4_MAC_REMOTE_MSB_OFFSET 0
`define WR_TRANSMISSION_RX_CFG4_MAC_REMOTE_MSB 32'h0000ffff
`define ADDR_WR_TRANSMISSION_RX_CFG5   7'h54
`define WR_TRANSMISSION_RX_CFG5_FIXED_LATENCY_OFFSET 0
`define WR_TRANSMISSION_RX_CFG5_FIXED_LATENCY 32'h0fffffff
`define ADDR_WR_TRANSMISSION_CFG       7'h58
`define WR_TRANSMISSION_CFG_OR_TX_ETHTYPE_OFFSET 0
`define WR_TRANSMISSION_CFG_OR_TX_ETHTYPE 32'h00000001
`define WR_TRANSMISSION_CFG_OR_TX_MAC_LOC_OFFSET 1
`define WR_TRANSMISSION_CFG_OR_TX_MAC_LOC 32'h00000002
`define WR_TRANSMISSION_CFG_OR_TX_MAC_TAR_OFFSET 2
`define WR_TRANSMISSION_CFG_OR_TX_MAC_TAR 32'h00000004
`define WR_TRANSMISSION_CFG_OR_RX_ETHERTYPE_OFFSET 16
`define WR_TRANSMISSION_CFG_OR_RX_ETHERTYPE 32'h00010000
`define WR_TRANSMISSION_CFG_OR_RX_MAC_LOC_OFFSET 17
`define WR_TRANSMISSION_CFG_OR_RX_MAC_LOC 32'h00020000
`define WR_TRANSMISSION_CFG_OR_RX_MAC_REM_OFFSET 18
`define WR_TRANSMISSION_CFG_OR_RX_MAC_REM 32'h00040000
`define WR_TRANSMISSION_CFG_OR_RX_ACC_BROADCAST_OFFSET 19
`define WR_TRANSMISSION_CFG_OR_RX_ACC_BROADCAST 32'h00080000
`define WR_TRANSMISSION_CFG_OR_RX_FTR_REMOTE_OFFSET 20
`define WR_TRANSMISSION_CFG_OR_RX_FTR_REMOTE 32'h00100000
`define WR_TRANSMISSION_CFG_OR_RX_FIX_LAT_OFFSET 21
`define WR_TRANSMISSION_CFG_OR_RX_FIX_LAT 32'h00200000
`define ADDR_WR_TRANSMISSION_DBG_CTRL  7'h5c
`define WR_TRANSMISSION_DBG_CTRL_MUX_OFFSET 0
`define WR_TRANSMISSION_DBG_CTRL_MUX 32'h00000001
`define WR_TRANSMISSION_DBG_CTRL_START_BYTE_OFFSET 8
`define WR_TRANSMISSION_DBG_CTRL_START_BYTE 32'h0000ff00
`define ADDR_WR_TRANSMISSION_DBG_DATA  7'h60
`define ADDR_WR_TRANSMISSION_DBG_RX_BVALUE 7'h64
`define ADDR_WR_TRANSMISSION_DBG_TX_BVALUE 7'h68
`define ADDR_WR_TRANSMISSION_DUMMY     7'h6c
`define WR_TRANSMISSION_DUMMY_DUMMY_OFFSET 0
`define WR_TRANSMISSION_DUMMY_DUMMY 32'hffffffff
