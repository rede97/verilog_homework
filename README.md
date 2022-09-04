# Verilog Homework

## VCS

1. Show all avaliable targets
```bash
$ cd sim
$ make
rm -rf csrc simv.* *.vpd ucli.key *_log spi_master_tb fsm_seq_4bit_tb async_fifo_tb apb_spi_tb ahb_spi_tb uart_tx_rx_tb general_syncer_tb sync_fifo_tb reset_synchronizer_tb* *.fsdb verdiLog *.conf *.log DVEfiles *.daidir *.rc *.tcl
Build Targtes [spi_master_tb fsm_seq_4bit_tb async_fifo_tb apb_spi_tb ahb_spi_tb uart_tx_rx_tb general_syncer_tb sync_fifo_tb reset_synchronizer_tb]
RUN CLI Targets [spi_master_tb.x fsm_seq_4bit_tb.x async_fifo_tb.x apb_spi_tb.x ahb_spi_tb.x uart_tx_rx_tb.x general_syncer_tb.x sync_fifo_tb.x reset_synchronizer_tb.x]
RUN DVE Targtes [spi_master_tb.dve fsm_seq_4bit_tb.dve async_fifo_tb.dve apb_spi_tb.dve ahb_spi_tb.dve uart_tx_rx_tb.dve general_syncer_tb.dve sync_fifo_tb.dve reset_synchronizer_tb.dve]
VERDI Targets [spi_master_tb.vd fsm_seq_4bit_tb.vd async_fifo_tb.vd apb_spi_tb.vd ahb_spi_tb.vd uart_tx_rx_tb.vd general_syncer_tb.vd sync_fifo_tb.vd reset_synchronizer_tb.vd]
```
2. Build target

```bash
$ make sync_fifo_tb
```

3. Run target in CLI mode
```
$ make sync_fifo_tb.x
```

4. Run target in DVE mode
```
make sync_fifo_tb.dve
```

5. Run target and display signal in verdi
```
make sync_fifo_tb.vd
```