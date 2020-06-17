*** Settings ***
Library                       Process
Library                       net_library.py
Suite Setup                   Setup
Suite Teardown                Teardown
Test Teardown                 Test Teardown
Resource                      ${RENODEKEYWORDS}

*** Variables ***
${AUDIO_INPUT}                https://dl.antmicro.com/projects/renode/Hector_Berlioz-Symphonie_fantastique--fragment.pcm24_44100.raw-s_818688-df45928fe2c64a9f0022d255e78738c5f341450a

*** Test Cases ***
Should Echo Audio
    ${input_file}=   Download File  ${AUDIO_INPUT}

    Execute Command           mach create
    Execute Command           machine LoadPlatformDescription @${CURDIR}/litex_zephyr_vexriscv_i2s.repl
    Execute Command           showAnalyzer sysbus.uart
    Execute Command           sysbus LoadELF @https://dl.antmicro.com/projects/renode/litex_i2s--zephyr-echo_sample.elf-s_1172756-db2f7eb8c6c8f396651b2f2d517cee13d79a9a69

    ${output_file}=  Allocate Temporary File

    Execute Command           sysbus.i2s_tx Output @${output_file}
    Execute Command           sysbus.i2s_rx LoadPCM @${input_file}
    Execute Command           sysbus.i2s_rx Start 100

    # sample input file is around 3s long, but let's give some more time for processing
    Execute Command           emulation RunFor "3.2"

    ${input_file_size}=  Get File Size  ${input_file}
    ${output_file_size}=  Get File Size  ${output_file} 

    Should Be Equal  ${input_file_size}  ${output_file_size}

    ${input_file_content}=  Get Binary File  ${input_file}
    ${output_file_content}=  Get Binary File  ${output_file}

    Should Be Equal  ${input_file_content}  ${output_file_content}

