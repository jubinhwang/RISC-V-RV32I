# RISC-V-RV32I
A 32-bit single-cycle processor based on the RISC-V (RV32I) instruction set architecture. This project implements 37 core instructions using a Harvard architecture with separate instruction and data memories

# RISC-V RV32I 단일 사이클 CPU 설계

[![Made with SystemVerilog](https://img.shields.io/badge/Made%20with-SystemVerilog-1f425f.svg)](https://www.systemverilog.io/)
[![Vivado-2020.2](https://img.shields.io/badge/Vivado-2020.2-blue.svg)](https://www.xilinx.com/)
[![ISA-RV32I](https://img.shields.io/badge/ISA-RV32I-blue.svg)](https://riscv.org/technical/specifications/)

'Harman semicon academy 2기' 프로젝트로, **SystemVerilog HDL**을 사용하여 RISC-V 아키텍처 기반의 32비트 단일 사이클 CPU 코어를 설계하고 검증했습니다.

본 프로젝트는 컴퓨터 구조의 핵심 원리를 이해하고, 명령어 디코딩부터 실행에 이르는 데이터패스와 제어 유닛을 구현하여 CPU의 동작 방식을 학습하는 것을 목표로 합니다. 단일 사이클 구조를 채택하여 각 명령어의 실행 과정을 명확히 파악하고, 시뮬레이션을 통해 모든 기능의 정확성을 검증했습니다.

## ✨ 주요 기능

* **단일 사이클 아키텍처 (Single-Cycle Architecture)**
    모든 명령어가 한 클럭 사이클 내에 Fetch, Decode, Execute, Memory, Write-back 단계를 모두 완료하는 간단한 구조입니다. 이를 통해 CPU의 기본 동작 흐름을 직관적으로 이해할 수 있습니다.

* **RISC-V ISA (RV32I) 구현**
    RISC-V의 기본 32비트 정수 명령어 집합(RV32I)에 포함된 37개의 명령어를 모두 구현했습니다. 산술/논리, 메모리 접근, 분기 등 필수적인 기능을 모두 지원합니다.

* **하버드 구조 (Harvard Architecture)**
    명령어와 데이터 메모리를 물리적으로 분리하여 CPU가 명령어 인출과 데이터 접근을 동시에 수행할 수 있도록 했습니다. 이는 폰 노이만 구조의 병목 현상을 해결하고 성능을 극대화하는 데 유리합니다.

* **명령어 포맷 지원**
    RV32I의 모든 명령어 형식(**R, I, S, B, U, J-Type**)을 지원하여 다양한 종류의 연산과 프로그램 흐름 제어가 가능합니다.

## 🛠️ 시스템 아키텍처

CPU는 명령어에 따라 데이터 흐름을 결정하는 **제어 유닛**과 실제 연산을 수행하는 **데이터패스**, 그리고 명령어와 데이터를 저장하는 **메모리**로 구성됩니다.

1.  **제어 유닛 (Control Unit)**
    명령어 메모리에서 읽어온 32비트 명령어를 해독하여, 데이터패스의 각 장치(ALU, MUX 등)에 필요한 모든 제어 신호를 생성합니다. `RegWrite`, `ALUOp`, `MemWrite` 등 각 모듈의 동작 타이밍과 데이터 흐름을 총괄합니다.

2.  **데이터패스 (Datapath)**
    제어 유닛의 신호에 따라 실제 명령어 실행을 담당하는 하드웨어 블록입니다. 내부적으로 **프로그램 카운터(PC)**, **명령어 레지스터**, 32개의 범용 **레지스터 파일**, 산술/논리 연산을 수행하는 **ALU** 등으로 구성되어 있습니다.

3.  **메모리 (Memory)**
    하버드 구조에 따라 명령어와 데이터 메모리가 분리되어 있습니다.
    * **명령어 메모리 (ROM)**: CPU가 실행할 기계어 코드를 저장하는 읽기 전용 메모리입니다.
    * **데이터 메모리 (RAM)**: `Load`/`Store` 명령어의 대상이 되는 주 데이터 저장소입니다. `sw`, `sh`, `sb` 명령어에 따라 32/16/8비트 단위의 데이터 쓰기를 지원합니다.

## 📖 명령어 포맷 상세 설명

본 CPU에서 처리하는 RV32I 명령어들은 기능에 따라 6가지 포맷으로 구분됩니다.

| 포맷       | 설명                                                                 | 주요 명령어 예시                  |
| :--------- | :------------------------------------------------------------------- | :-------------------------------- |
| **R-Type** | 두 레지스터의 값을 연산하여 결과 레지스터에 저장 (Register-Register) | `add`, `sub`, `sll`, `slt`, `xor`   |
| **I-Type** | 레지스터와 상수(immediate) 값을 연산하거나 메모리에서 데이터 로드      | `addi`, `slti`, `lw`, `jalr`        |
| **S-Type** | 레지스터의 값을 메모리에 저장 (Store)                      | `sw`, `sh`, `sb`                  |
| **B-Type** | 두 레지스터 값을 비교하여 조건에 따라 분기(branch)    | `beq`, `bne`, `blt`               |
| **U-Type** | 20비트 상수를 레지스터의 상위 비트에 적재 (Upper Immediate) | `lui`, `auipc`                    |
| **J-Type** | 지정된 주소로 무조건 점프(jump)                            | `jal`                             |


## 🚀 시작하기 (Getting Started)

#### ✅ 사전 요구사항 (Prerequisites)
* 💻 **FPGA 개발 환경**: **Xilinx Vivado 2020.2**
* 🧪 **시뮬레이션 툴**: Vivado 내장 시뮬레이터 

#### 🛠️ 설치 및 실행 절차 (Step-by-Step Guide)

1.  **📂 프로젝트 다운로드 및 설정**
    ```bash
    git clone [여기에-저장소-URL-붙여넣기]
    ```

2.  **🧪 시뮬레이션 실행**
    1.  Vivado에서 `Simulation Sources`에 포함된 테스트벤치 파일을 확인합니다.
    2.  **`Run Simulation`**을 클릭하여 시뮬레이션을 실행합니다.
    3.  Waveform 창에서 PC(Program Counter)가 올바르게 증가하는지, 분기 명령어에 따라 목표 주소로 점프하는지 확인합니다.
    4.  ALU 연산 결과가 목적지 레지스터(`rd`)에 정확히 쓰이는지, `Store`/`Load` 명령어에 따라 데이터 메모리와 레지스터 간 데이터 전송이 올바른지 검증합니다.

## 🔧 트러블슈팅 (Troubleshooting)

**문제: `LB/LH` 명령어 오류 해결**
* **현상**: Word(4-byte) 단위로 정렬되지 않은 주소에 `LB`(Load Byte) 또는 `LH`(Load Half-word) 명령어로 접근 시 데이터를 읽어오지 못하는 문제가 발생했습니다.
* **원인**: 초기 메모리 설계가 Word 주소 단위로만 접근 가능하여, Byte 단위 주소를 해석하는 로직이 부재했습니다.
* **해결**: 주소 디코딩 로직을 추가하여 입력된 Byte 주소를 **Word 주소**와 **Word 내 Byte 위치(offset)**로 분리했습니다. 이를 통해 Word 단위로 데이터를 읽어온 후, offset을 이용해 정확한 Byte나 Half-word를 추출하도록 수정하여 문제를 해결했습니다.

## 🤔 고찰 (Reflections)

프로젝트를 진행하며 다음과 같은 점들을 배우고 느꼈습니다.
* **CPU 동작 원리에 대한 깊이 있는 이해**: 각 명령어의 기능을 정확히 이해하는 것이 시뮬레이션을 위한 ROM 코드 작성의 첫걸음임을 깨달았습니다. 잘못된 코드는 디버깅을 매우 어렵게 만들었습니다.
* **디버깅의 중요성**: 시뮬레이션 시 확인해야 할 신호가 매우 많아 초기에는 어려움을 겪었습니다. 특히 제어 유닛에서 나오는 신호들을 추적하며 데이터패스의 흐름을 파악하는 과정에서 디버깅 능력이 향상되었습니다.
* **문서화의 가치**: 발표 자료(PPT)를 제작하며 프로젝트를 되돌아보는 과정이 개념을 정리하는 데 큰 도움이 되었습니다. 왜 각 명령어 타입이 필요하며, 향후 기능 확장을 위해 어떤 부분을 수정해야 하는지 명확히 알 수 있었습니다.

## 📈 개선 및 보완점
* **파이프라인 아키텍처 도입**: 성능 향상을 위해 5-stage 파이프라인(IF-ID-EX-MEM-WB) 구조로 확장
* **명령어 세트 확장**: 곱셈/나눗셈을 위한 'M' 확장(RV32IM) 등 추가 명령어 세트 구현
* **예외 처리(Exception) 및 인터럽트(Interrupt) 기능 추가**: 외부 신호나 내부 오류에 대응할 수 있는 고급 기능 구현


**개발자**: 황주빈 (Jubin Hwang)
