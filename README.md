# PCF8575-I2C-Verilog-FPGA
---

## 📌 Overview

This project implements a **custom I²C master controller** in **Verilog** to interface with the **PCF8575 16-bit I/O expander**.
The design has been **simulated, waveform-verified against the I²C specification**, and **successfully tested on real FPGA hardware**.

* FPGA platform: **Tang Nano 20K**
* Protocol: **I²C Fast-mode (up to 400 kHz)**
* Language: **Verilog HDL**

---

## ✨ Features

* Full I²C master functionality:

  * START / STOP conditions
  * 7-bit slave addressing
  * Read & write transactions
  * ACK / NACK handling
* **FSM-based bit-level control**
* **Open-drain SDA/SCL implementation**
* **Interrupt-driven read** using PCF8575 `INT` signal
* Clean separation of **data update and sampling phases**

---

## ⏱ Clocking & Timing

* FSM clocked at **800 kHz**
* Generated **400 kHz SCL** (I²C Fast-mode compliant)
* 2× clocking strategy ensures:

  * SDA updates only during SCL LOW
  * Stable data sampling during SCL HIGH

---

## 🧩 Architecture

* **Top module**

  * PLL-based clock generation
  * Integration of all submodules
* **PCF8575 I²C Master**

  * FSM controlling I²C protocol phases
  * SDA/SCL open-drain drive logic
* **Shift / Pattern Generator**

  * Periodic update of write data

---

## 🧪 Verification

* Developed **testbench for I²C protocol**
* Simulated and checked waveforms:

  * START / STOP timing
  * Address and data phases
  * ACK/NACK behavior
* Verified timing compliance with **I²C specification**
* Validated communication with a **real PCF8575 module on FPGA**

---

## 🔌 Hardware Setup

* **FPGA Board:** Tang Nano 20K
* **Peripheral:** PCF8575 I/O Expander
* **Signals:**

  * `SCL_bus` – I²C clock (open-drain)
  * `SDA_bus` – I²C data (bidirectional, open-drain)
  * `INT` – Interrupt input from PCF8575

---

## 📄 License

MIT License

