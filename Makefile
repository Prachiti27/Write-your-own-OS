ASM=nasm

SRC_DIR=src
BUILD_DIR=build

.PHONY: all floppy_image kernel bootloader clean always

#Floppy image
floppy_image: $(BUILD_DIR)/main_floppy.img

$(BUILD_DIR)/main_floppy.img: bootloader kernel
	dd if=/dev/zero of=$(BUILD_DIR)/main_floppy.img bs=512 count=2880
	mkfs.fat -F 12 -n "NBOS" $(BUILD_DIR)/main_floppy.img	
#writes BIOS parameter(BPB) into first sector of image
	dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/main_floppy.img conv=notrunc
#copies compiled bootloader directly in floppy image
	mcopy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/kernel.bin "::kernel.bin"
#copies kernel.bin file in to root directory of floppy image

#bootloader
bootloader: $(BUILD_DIR)/bootloader.bin

$(BUILD_DIR)/bootloader.bin: always
	$(ASM) $(SRC_DIR)/bootloader/boot.asm -f bin -o $(BUILD_DIR)/bootloader.bin

#kernel

kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(ASM) $(SRC_DIR)/kernel/main.asm -f bin -o $(BUILD_DIR)/kernel.bin

always: 
	mkdir -p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)/*