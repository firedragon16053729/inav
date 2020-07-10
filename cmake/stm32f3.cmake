include(cortex-m4f)
include(stm32-stdperiph)
include(stm32f3-usb)

set(STM32F3_STDPERIPH_DIR "${INAV_LIB_DIR}/main/STM32F3/Drivers/STM32F30x_StdPeriph_Driver")
set(STM32F3_CMSIS_DEVICE_DIR "${INAV_LIB_DIR}/main/STM32F3/Drivers/CMSIS/Device/ST/STM32F30x")
set(STM32F3_CMSIS_DRIVERS_DIR "${INAV_LIB_DIR}/main/STM32F3/Drivers/CMSIS")
set(STM32F3_VCP_DIR "${INAV_MAIN_SRC_DIR}/vcp")

set(STM32F3_STDPERIPH_SRC_EXCLUDES
    stm32f30x_crc.c
    stm32f30x_can.c
)
set(STM32F3_STDPERIPH_SRC_DIR "${STM32F3_STDPERIPH_DIR}/Src")
glob_except(STM32F3_STDPERIPH_SRC "${STM32F3_STDPERIPH_SRC_DIR}/*.c" STM32F3_STDPERIPH_SRC_EXCLUDES)


set(STM32F3_SRC
    target/system_stm32f30x.c
    drivers/adc_stm32f30x.c
    drivers/bus_i2c_stm32f30x.c
    drivers/dma_stm32f3xx.c
    drivers/serial_uart_stm32f30x.c
    drivers/system_stm32f30x.c
    drivers/timer_impl_stdperiph.c
    drivers/timer_stm32f30x.c
)
main_sources(STM32F3_SRC)

set(STM32F3_VCP_SRC
    hw_config.c
    stm32_it.c
    usb_desc.c
    usb_endp.c
    usb_istr.c
    usb_prop.c
    usb_pwr.c
)
list(TRANSFORM STM32F3_VCP_SRC PREPEND "${STM32F3_VCP_DIR}/")

set(STM32F3_INCLUDE_DIRS
    "${CMSIS_INCLUDE_DIR}"
    "${CMSIS_DSP_INCLUDE_DIR}"
    "${STM32F3_STDPERIPH_DIR}/inc"
    "${STM32F3_CMSIS_DEVICE_DIR}"
    "${STM32F3_CMSIS_DRIVERS_DIR}"
    "${STM32F3_VCP_DIR}"
)

set(STM32F3_DEFINITIONS
    ${CORTEX_M4F_DEFINITIONS}
    STM32F3
    USE_STDPERIPH_DRIVER
)

set(STM32F303_DEFINITIONS
    STM32F303
    STM32F303xC
    FLASH_SIZE=256
)

function(target_stm32f3xx name startup ldscript)
    # F3 targets don't support MSC
    target_stm32(${name} ${startup} ${ldscript} DISABLE_MSC ${ARGN})
    target_sources(${name} PRIVATE ${STM32_STDPERIPH_SRC} ${STM32F3_STDPERIPH_SRC} ${STM32F3_SRC})
    target_compile_options(${name} PRIVATE ${CORTEX_M4F_COMMON_OPTIONS} ${CORTEX_M4F_COMPILE_OPTIONS})
    target_include_directories(${name} PRIVATE ${STM32F3_INCLUDE_DIRS})
    target_compile_definitions(${name} PRIVATE ${STM32F3_DEFINITIONS})
    target_link_options(${name} PRIVATE ${CORTEX_M4F_COMMON_OPTIONS} ${CORTEX_M4F_LINK_OPTIONS})

    get_property(features TARGET ${name} PROPERTY FEATURES)
    if(VCP IN_LIST features)
        target_include_directories(${name} PRIVATE ${STM32F3_USB_INCLUDE_DIRS})
        target_sources(${name} PRIVATE ${STM32F3_USB_SRC} ${STM32F3_VCP_SRC})
    endif()
endfunction()

function(target_stm32f303 name)
    target_stm32f3xx(${name} startup_stm32f30x_md_gcc.S stm32_flash_f303_256k.ld ${ARGN})
    target_compile_definitions(${name} PRIVATE ${STM32F303_DEFINITIONS})
    setup_firmware_target(${name})
endfunction()
