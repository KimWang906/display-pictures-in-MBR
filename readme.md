# Display Pictures In MBR

## convert asm -> bin

### Windows

```bat
convert

cd nasm-2.15.05`
.\nasm -f bin ..\main.asm -o ..\output.bin

run bin file

.\qemu-system-x86_64 (my location)\main.bin
```
