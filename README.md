## CPU-Computer Organization and Design

## 武汉大学计算机学院 计算机组成与设计课程设计

基于RISC-V的单周期、流水线CPU设计verilog实现。

单周期的代码在 `lab-single/` 里。

没有冒险的流水线代码在 `lab-pipeline/` 里。

带有冒险的流水线代码在 `lab-ppl-ha/` 里。

---

用于 **SWORD** 的单周期在 `cpu622/`；

用于 **SWORD** 冒险流水线代码在 `cpu625/`；

最终提交版本（课程报告中的版本）在 `cpu702/`（完成时间：2022年7月11日）

最终版本为简单消除游戏（灵感来源：消灭星星），但上板后仍有一些问题待修复。

---

There is single cycle and pipelined CPU.

Single cycle is in `lab-single`.

Pipelined(without hazard resolution) is in `lab-pipeline`.(However, control hazards might be solved.)

Pipelined with hazard is in `lab-ppl-ha`.

---

Single CPU for **SWORD** is in `cpu622`.

Pipelined with hazard for **SWORD** is in `cpu625`.

Final submitted program is in `cpu702`(finished in 11 Jul, 2022)
