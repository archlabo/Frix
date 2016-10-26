# Frix (Feasible and Reconfigurable IBM PC Compatible SoC)
(Note: This system is based on [ao486](https://github.com/alfikpl/ao486) project)

After 34 years has passed since IBM PC was released,
we succeeded to reproduce IBM PC on a FPGA board at last.
This SoC is an IBM PC Compatible system which can run the same software for old IBM PC.

This SoC contains a x86 softcore processor and other peripheral modules written in verilog HDL
and is capable of running general purpose operating system.

This runs on a Digilent's Nexys4, Nexys4 DDR and Terastic's DE2-115 board.

The system block diagram is shown below:

![newSoC_block.png](https://qiita-image-store.s3.amazonaws.com/0/93335/33814d5b-e9d1-3d8b-530a-c6810c7807bc.png "newSoC_block.png")

We use several ao486 modules for this system:
processor, VGA controller, PS/2 controller, PIT, RTC and HDD module. 
We newly wrote BIOS loader module and bus module in Verilog HDL in order to replace Altera's NIOS II and Avalon bus in ao486.


## Tutorial

### Prepare
1.Clone Frix project from GitHub

```
git clone https://github.com/archlabo/Frix.git
```

2.Get required modules from ao486 project

```
cd Frix && git submodule update --init
```

3.Apply our patch to ao486 modules 

```
cd ao486
patch -p1 < ../misc/ao486/ao486.patch
```


### Build project


#### Nexys4 (Nexys4 DDR)
Nexys4 or Nexys4 DDR has Xilinx Artix-7 FPGA.
You can use Vivado software for logic synthesis.
We comfirmed our system, which is compiled on Vivado 2014.1-2, 2015.2-4 and 2016.2, can boot.

1.Open fpga/nexys4(_ddr)/project/project.xpr

2.Click Generate Bitstream for logic synthesis

3.After finishing logic synthesis, comfirm Frix.bit is created

#### DE2-115

DE2-115 has Altera Cyclone IV FPGA.
You can use Quartus II software for logic synthesis.

1.Open fpga/de2-115/project/project.qpf

2.Click Compile Design for logic synthesis

3.After finishing logic synthesis, comfirm project.sof is created


### (micro)SD card
Nexys4 and Nexys4 DDR have each micro SD card slot, and DE2-115 has SD card slot.
Store both BIOS image and disk image to SD card using dd command (Note /dev/diskX is for Mac OS, other OS may use different name):

```

dd if=bios_vgabios.dat of=/dev/diskX bs=102400 seek=0
dd if=***.img of=/dev/diskX bs=102400 seek=512

```

Our example hdd image and bios file is published in following web site.
You need to get our hdd image there or create new hdd image by yourself.
If you want to create new hdd image, see 'Make Disk Image' section.
[Frix web site](http://www.arch.cs.titech.ac.jp/a/Frix/)


### Hardware connection

Prepare these following equipments and connect each other.
- FPGA board (Nexys4/Nexys4 DDR/DE2-115)
- Display (VGA port)
- Keyboard (without USB hub)
- (micro)SD card (Stored hdd image)

Some keyboards and displays don't work well at our system.
Please try several types of them.

### Run

1.Turn on power to all equipments

2.Program generated bit file to your FPGA 

- Nexys4/Nexys4 DDR: Expand Hardware Manager and click Program Device by Vivado 
- DE2-115: Open Device Manager from Quartus II

3.Congratulations! Frix system must be running!
Examples:
- FreeDOS: 
```
cd GAME/DOOMS 
DOOM  
```
- TinyCore:
```
cd /mnt/sda1/app 
./sl 
```

We publicate 2 types of hdd images at [Frix web site](http://www.arch.cs.titech.ac.jp/a/Frix/)
One is FreeDOS 1.1, which has DOOM, the first FPS game.
The Other is TinyCore 5.3, which can use [sl command](http://github.com/mtoyoda/sl).
Try to run and enjoy these applications!

---

## Make Disk Image
Note that these disk image can be used for both this SoC and ao486.

### FreeDOS
Download CD image from [official site](http://www.freedos.org/) and install FreeDos to virtual disk by using QEMU or VirtualBox.

Note that due to specification of hardware driver in ao486 (IDE), the size of virtual disk must be smaller than about 500MB. Also we have to convert virtual disk format (vdi etc.) to raw format. If you use virtual box, use following command in terminal:

```
 VBoxManage clonehd freedos.vdi freedos.img --format raw
```

You can boot raw disk image using QEMU:

```
qemu-system-i386 freedos.img
```

### TinyCore
(Note: We used vesion 5.3)

Download the most smallest 'Core' disk image (CUI only, about 8MB) from [official site](http://distro.ibiblio.org/tinycorelinux/downloads.html) and install to virtual. We refered this [site](http://firewallengineer.wordpress.com/2013/07/30/first-attempt-to-install-tiny-core-linux-to-hard-disk/). Note that you may need to change URL in /opt/tcemirror file to "http://distro.ibiblio.org/tinycorelinux" in order to use tce-load command.

Then convert the virtual disk image to raw format like FreeDOS.

#### Replace Kernel Image
(Note: we did this on ubuntu 14)

After installing tinycore to disk, we have to replace kernel image in order to run it on ao486. This is because 1). ao486 has no CR4 register and we have to commentout kernel code which access to CR4 and 2). ao486 has no FPU and we have to set kernel math emuration function.
(Minimum requirement for tinycore is i486 DX)

1.Download kernel source code and config file.
Files are located at "http://distro.ibiblio.org/tinycorelinux/5.x/x86/release/src/kernel/"

```
wget http://distro.ibiblio.org/tinycorelinux/5.x/x86/release/src/kernel/linux-3.8.10-patched.txz
```

2.Extract the folder and apply our patch

```
tar Jxvf linux-3.8.10-patched.txz
cd linux-3.8.10-patched
patch -p2 -d . < misc/tinycore/patch_ao486
```

This patch modify these files and comment out some lines which access CR4:
- arch/x86/kernel/relocate_kernel_32.S
- arch/x86/kernel/cpu/mtrr/generic.c
- arch/x86/kernel/process_32.c
- arch/x86/kernel/setup_32.c

3.Configure kernel options.
Copy our config file to top directory as '.config'.
We have to specify 'ARCH=i386' for 32-bit compilation.

```
cp misc/tinycore/config-ao486 .config
make ARCH=i386 oldconfig
```
If you want to change some options, use ```make ARCH=i386 menuconfig```.

Note this config file is based on 'http://distro.ibiblio.org/tinycorelinux/5.x/x86/release/src/kernel/linux-3.8.10-config'
and we modified:

- ON : Processor type and features -> Math emulation
- OFF : Processor type and features -> Paravirtualized guest support 
- OFF : Virtualization

These changes are enough to run OS on ao486, but we also turned off some unnecessary options to shorten compile and boot time:

- OFF : General Setup -> Optimize for size
- OFF : Processor type and features -> symmetric multi-processing support
- OFF : Processor type and features -> Generic x86 support
- OFF : Processor type and features -> High Memory Support
- OFF : Processor type and features -> MTRR support
- OFF : Device Drivers -> USB support


4.Compile kernel. Use -j option for parallel compilation.

```
make ARCH=i386 bzImage -j8
```
arch/x86/boot/bzImage is compiled kernel image.

5.Copy the kernel image to (mounted) hdd image.

```
mkdir mnt
sudo mount -o loop,offset=32256 tinycore.img mnt
cd mnt/boot
sudo cp linux-3.8.10-patched/arch/x86/boot/bzImage vmlinuz-modified
```

6.Edit grub menulist. First open the file:

```
sudo vi grub/menu.lst
```
Then add following lines:

```
 title core
 kernel /boot/vmlinuz-modified loglevel=7 text no387 nofxsr nortc
 initrd /boot/core.gz
```

Note we have to specify "no387 nofxsr nortc" for boot option.

7.Unmount the disk image.

```
sudo umount mnt
```
## FAQ
####Q.
What is bios_vgabios.dat
####A.
This file is essentialy concatenation of bios + vgabios.

Instead of using this, you can dd each bios file by:
```
dd if=ao486/sd/bios/bochs_legacy of=/dev/diskX bs=512 seek=72
dd if=ao486/sd/vgabios/vgabios-lgpl of=/dev/diskX bs=512 seek=8
```
Note that we modified bios in bios_vgabios.dat to boot without keyboard. See below question.

####Q.
BIOS hangs without keyboard when using original bios files (ao486/sd/bios,vgabios).
####Q. 
I can't get any video output other than a blank screen with Nexys4 (DDR) when using original bios files. 
####A. 
If keyboard is not connected, original BIOS calls BX_PANIC.
Also, PS/2 port on Nexys4 board may be unstable, so BIOS calls BX_PANIC function and stops the system.
For the second case, to reset FPGA with BTNC several times may work.

To solve this problem, you have to recompile bios. Download and extract the bochs-2.6.2 source archive, then apply the patch in the same way of ao486, comment out 1967 line of bios/rombios.c, and finally compile it.
This line call BX_PANIC when keyboard causes a error. (this has been done for bios_vgabios.dat)

####Q.
Keyboard does not work on Nexys4 (DDR)
####A.
The keyboard which has USB function does not work with Nexys4 (DDR).

####Q.
What LED Outputs mean?
####A.
Please see top module (i.e. Frix/fpga/nexys4/rtl/soc.v etc.)
