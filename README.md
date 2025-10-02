# RISC-V-RV32I
A 32-bit single-cycle processor based on the RISC-V (RV32I) instruction set architecture. This project implements 37 core instructions using a Harvard architecture with separate instruction and data memories

# RISC-V RV32I 단일 사이클 CPU 설계

[![Made with Verilog](https://img.shields.io/badge/Made%20with-Verilog-1f425f.svg)](https://verilog.org/)
[![ISA-RV32I](https://img.shields.io/badge/ISA-RV32I-blue.svg)](https://riscv.org/technical/specifications/)

'Harman semicon academy 2기' 프로젝트로, System Verilog을 사용하여 RISC-V 아키텍처 기반의 32비트 단일 사이클 CPU 코어를 설계하고 검증했습니다.

본 프로젝트는 컴퓨터 구조의 핵심 원리를 이해하고, 명령어 디코딩부터 실행에 이르는 데이터패스와 제어 유닛을 직접 구현하여 CPU의 동작 방식을 학습하는 것을 목표로 합니다.

## ✨ 주요 기능

* **단일 사이클 아키텍처**: 모든 명령어가 한 클럭 사이클 내에 완료되는 간단하고 교육적인 구조로 설계되었습니다.
* **RISC-V ISA 구현**: RV32I 기본 정수 명령어 집합의 37개 명령어를 모두 구현했습니다.
* **하버드 구조**: 명령어와 데이터 메모리를 물리적으로 분리하여 병목 현상을 줄이고 동시 접근이 가능하도록 설계했습니다.
* **모듈식 설계**: **제어 유닛(Control Unit)**, **데이터패스(Datapath)**, **메모리(Memory)** 등 주요 기능을 모듈 단위로 나누어 설계하여 가독성과 확장성을 높였습니다.
* **완전한 명령어 포맷 지원**: **R, I, S, B, U, J-Type** 등 RV32I의 모든 명령어 형식을 지원합니다.
* **시뮬레이션 기반 검증**: 각 명령어 타입별 시나리오를 작성하고 시뮬레이션을 통해 기능의 정확성을 철저히 검증했습니다.

## 🛠️ 시스템 아키텍처

CPU는 명령어에 따라 데이터 흐름을 결정하는 **제어 유닛**과 실제 연산을 수행하는 **데이터패스**, 두 핵심 부분으로 구성됩니다.

1.  **제어 유닛 (Control Unit)**: **명령어 메모리(ROM)**에서 읽어온 32비트 명령어를 해석하여, 데이터패스의 각 장치(ALU, MUX 등)에 필요한 제어 신호를 생성합니다.
2.  **데이터패스 (Datapath)**: 제어 신호에 따라 레지스터 파일의 값을 읽고, ALU 연산을 수행하며, 그 결과를 레지스터나 **데이터 메모리(RAM)**에 쓰는 등 실제 명령어 실행을 담당합니다.
3.  **메모리 (Memory)**: 하버드 구조에 따라 명령어 메모리(ROM)와 데이터 메모리(RAM)가 분리되어 있습니다.

## 📖 명령어 포맷 (Instruction Formats)

본 CPU에서 처리하는 RV32I 명령어들은 기능에 따라 6가지 포맷으로 구분됩니다.

| 포맷 | 설명 | 주요 명령어 예시 |
| :--- | :--- | :--- |
| **R-Type** | 두 레지스터의 값을 연산하여 결과 레지스터에 저장 | `add`, `sub`, `sll`, `slt`, `xor` |
| **I-Type** | 레지스터와 상수(immediate) 값을 연산하거나 메모리에서 데이터 로드 | `addi`, `slti`, `lw`, `jalr` |
| **S-Type** | 레지스터의 값을 메모리에 저장 | `sw`, `sh`, `sb` |
| **B-Type** | 두 레지스터 값을 비교하여 조건에 따라 분기(branch) | `beq`, `bne`, `blt` |
| **U-Type** | 20비트 상수를 레지스터의 상위 비트에 적재 | `lui`, `auipc` |
| **J-Type** | 지정된 주소로 무조건 점프(jump) | `jal` |


## 🚀 시작하기 (Getting Started)

이 프로젝트를 시뮬레이션하거나 실제 **FPGA 보드**에 구현하기 위한 단계별 가이드입니다.

#### ✅ 사전 요구사항 (Prerequisites)
* 💻 **FPGA 개발 환경**: **Xilinx Vivado**
* 🤖 **FPGA 보드**: **Xilinx Artix-7** 기반 FPGA 보드 (e.g., Digilent Basys3)
* 🧪 **시뮬레이션 툴**: Vivado 내장 시뮬레이터 또는 ModelSim

#### 🛠️ 설치 및 실행 절차 (Step-by-Step Guide)

1.  **📂 프로젝트 다운로드 및 설정**

    먼저, GitHub 저장소의 파일을 PC로 복제(clone)하고 Vivado에서 프로젝트를 엽니다.
    ```bash
    git clone [여기에-저장소-URL-붙여넣기]
    ```

2.  **🧪 시뮬레이션 실행**

    Vivado에서 제공하는 시뮬레이션 기능을 통해 CPU의 동작을 검증합니다.
    1.  Vivado의 `Simulation Sources`에 포함된 테스트벤치 파일을 확인합니다.
    2.  **`Run Simulation`**을 클릭하여 시뮬레이션을 실행하고, Waveform 창에서 각 신호(레지스터 값, PC 주소 등)의 변화를 확인합니다.
    3.  ROM에 미리 정의된 명령어들이 순차적으로 실행되며 모든 기능이 정상 동작하는지 검증할 수 있습니다.

3.  **⚙️ (선택) FPGA 빌드 및 프로그래밍**

    1.  `constrs_1`에 사용하려는 FPGA 보드에 맞는 제약 조건 파일(.xdc)을 추가합니다.
    2.  **`Generate Bitstream`**을 클릭하여 `.bit` 파일을 생성합니다.
    3.  **Hardware Manager**를 열고, FPGA 보드를 PC에 연결한 후 생성된 비트스트림을 업로드합니다.

## 📈 개선 및 보완점
* **파이프라인 아키텍처 도입**: 성능 향상을 위해 5-stage 파이프라인(IF-ID-EX-MEM-WB) 구조로 확장
* **명령어 세트 확장**: 곱셈/나눗셈을 위한 'M' 확장(RV32IM) 등 추가 명령어 세트 구현
* **예외 처리(Exception) 및 인터럽트(Interrupt) 기능 추가**: 외부 신호나 내부 오류에 대응할 수 있는 고급 기능 구현


**개발자**: 황주빈 (Jubin Hwang)
