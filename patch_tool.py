import struct, shutil, subprocess

def patch_executable(src_path, dst_path):
    shutil.copyfile(src_path, dst_path)

    stub_rva = 0x15dec0
    return_rva = 0x1288d6

    iat = {
        'wsprintfW': 0x15ea30,
        'lstrcpyW': 0x15e390,
        'PathAppendW': 0x15e908,
        'GetFileAttributesW': 0x15e360,
        'GetModuleFileNameW': 0x15e358,
        'PathRemoveFileSpecW': 0x15e880,
        'ShellExecuteExW': 0x15e810,
    }

    def assemble(labels):
        b = bytearray()
        
        def cur_rva():
            return stub_rva + len(b)
            
        def rip_disp(target):
            return target - (cur_rva() + 6)
            
        def rip_disp_lea(target):
            return target - (cur_rva() + 7)

        # 1. Clear SHELLEXECUTEINFO
        b.extend(bytes.fromhex('0f 57 c0'))                 # xorps xmm0, xmm0
        b.extend(bytes.fromhex('0f 11 45 04'))              # movups [rbp+0x4], xmm0
        b.extend(bytes.fromhex('0f 11 45 14'))              # movups [rbp+0x14], xmm0
        b.extend(bytes.fromhex('0f 11 45 24'))              # movups [rbp+0x24], xmm0
        b.extend(bytes.fromhex('0f 11 45 30'))              # movups [rbp+0x30], xmm0
        b.extend(bytes.fromhex('48 c7 45 d0 70 00 00 00'))  # mov qword ptr [rbp-0x30], 0x70
        b.extend(bytes.fromhex('4c 89 7d e0'))              # mov [rbp-0x20], r15
        b.extend(bytes.fromhex('4c 89 6d d8'))              # mov [rbp-0x28], r13
        b.extend(bytes.fromhex('c7 45 00 01 00 00 00'))     # mov dword ptr [rbp], 1

        # 2. Set lpDirectory = rbp + 0x740 (current file directory)
        b.extend(bytes.fromhex('48 8d 85 40 07 00 00'))     # lea rax, [rbp+0x740]
        b.extend(bytes.fromhex('48 89 45 f8'))              # mov [rbp-0x8], rax

        # 3. Format lpParameters: wsprintfW(rbp+0xb40, szFmt, rsi)
        b.extend(bytes.fromhex('48 8d 8d 40 0b 00 00'))     # lea rcx, [rbp+0xb40]
        disp = rip_disp_lea(labels.get('szFmt', 0))
        b.extend(b'\x48\x8d\x15' + struct.pack('<i', disp))
        b.extend(bytes.fromhex('49 89 f0'))                 # mov r8, rsi
        disp = rip_disp(iat['wsprintfW'])
        b.extend(b'\xff\x15' + struct.pack('<i', disp))
        b.extend(bytes.fromhex('48 8d 85 40 0b 00 00'))     # lea rax, [rbp+0xb40]
        b.extend(bytes.fromhex('48 89 45 f0'))              # mov [rbp-0x10], rax

        # 4. Check if local run.bat exists in current file directory:
        # lstrcpyW(rbp+0x940, rbp+0x740)
        b.extend(bytes.fromhex('48 8d 8d 40 09 00 00'))     # lea rcx, [rbp+0x940]
        b.extend(bytes.fromhex('48 8d 95 40 07 00 00'))     # lea rdx, [rbp+0x740]
        disp = rip_disp(iat['lstrcpyW'])
        b.extend(b'\xff\x15' + struct.pack('<i', disp))

        # PathAppendW(rbp+0x940, szRunBat)
        b.extend(bytes.fromhex('48 8d 8d 40 09 00 00'))     # lea rcx, [rbp+0x940]
        disp = rip_disp_lea(labels.get('szRunBat', 0))
        b.extend(b'\x48\x8d\x15' + struct.pack('<i', disp))
        disp = rip_disp(iat['PathAppendW'])
        b.extend(b'\xff\x15' + struct.pack('<i', disp))

        # GetFileAttributesW(rbp+0x940)
        b.extend(bytes.fromhex('48 8d 8d 40 09 00 00'))     # lea rcx, [rbp+0x940]
        disp = rip_disp(iat['GetFileAttributesW'])
        b.extend(b'\xff\x15' + struct.pack('<i', disp))
        b.extend(bytes.fromhex('83 f8 ff'))                 # cmp eax, -1
        target = labels.get('exec_call', 0)
        rel8 = (target - (cur_rva() + 2)) & 0xff
        b.extend(b'\x75' + struct.pack('<B', rel8))         # jne exec_call

        # 5. Fallback to Notepad4 directory run.bat:
        # GetModuleFileNameW(NULL, rbp+0x940, 0x104)
        b.extend(bytes.fromhex('31 c9'))                     # xor ecx, ecx
        b.extend(bytes.fromhex('48 8d 95 40 09 00 00'))     # lea rdx, [rbp+0x940]
        b.extend(bytes.fromhex('41 b8 04 01 00 00'))         # mov r8d, 0x104
        disp = rip_disp(iat['GetModuleFileNameW'])
        b.extend(b'\xff\x15' + struct.pack('<i', disp))

        # PathRemoveFileSpecW(rbp+0x940)
        b.extend(bytes.fromhex('48 8d 8d 40 09 00 00'))     # lea rcx, [rbp+0x940]
        disp = rip_disp(iat['PathRemoveFileSpecW'])
        b.extend(b'\xff\x15' + struct.pack('<i', disp))

        # PathAppendW(rbp+0x940, szRunBat)
        b.extend(bytes.fromhex('48 8d 8d 40 09 00 00'))     # lea rcx, [rbp+0x940]
        disp = rip_disp_lea(labels.get('szRunBat', 0))
        b.extend(b'\x48\x8d\x15' + struct.pack('<i', disp))
        disp = rip_disp(iat['PathAppendW'])
        b.extend(b'\xff\x15' + struct.pack('<i', disp))

        # exec_call:
        labels['exec_call'] = cur_rva()
        b.extend(bytes.fromhex('48 8d 85 40 09 00 00'))     # lea rax, [rbp+0x940]
        b.extend(bytes.fromhex('48 89 45 e8'))              # mov [rbp-0x18], rax
        b.extend(bytes.fromhex('48 8d 4d d0'))              # lea rcx, [rbp-0x30]
        disp = rip_disp(iat['ShellExecuteExW'])
        b.extend(b'\xff\x15' + struct.pack('<i', disp))

        # jmp return_rva (5 bytes: E9 disp32)
        disp = return_rva - (cur_rva() + 5)
        b.extend(b'\xe9' + struct.pack('<i', disp))

        # Align strings to 2 bytes
        if len(b) % 2 != 0:
            b.append(0xcc)

        # szRunBat: L"run.bat\0"
        labels['szRunBat'] = cur_rva()
        b.extend('run.bat\0'.encode('utf-16le'))

        # szFmt: L"\"%s\"\0"
        labels['szFmt'] = cur_rva()
        b.extend('"%s"\0'.encode('utf-16le'))

        return b, labels

    labels = {}
    assemble(labels)
    stub_code, labels = assemble(labels)
    print(f'Stub code size: {len(stub_code)} bytes (0x{len(stub_code):x})')

    with open(dst_path, 'r+b') as f:
        # 1. Update PE section header for .text
        f.seek(0x210)
        sec_name = f.read(8)
        assert sec_name.startswith(b'.text'), f'Unexpected section name: {sec_name}'
        f.seek(0x218)
        f.write(struct.pack('<I', 0x15d000))
        print('Updated .text VirtualSize to 0x15d000')

        # 2. Write stub at raw 0x15d2c0 (RVA 0x15dec0)
        f.seek(0x15d2c0)
        f.write(stub_code)
        print(f'Wrote {len(stub_code)} bytes to raw 0x15d2c0')

        # 3. Patch Case 8 at raw 0x122947 (RVA 0x123547)
        # Original length is 74 bytes
        disp = stub_rva - (0x123547 + 5)
        patch_bytes = b'\xe9' + struct.pack('<i', disp) + b'\x90' * (74 - 5)
        f.seek(0x122947)
        f.write(patch_bytes)
        print('Patched Case 8 jump (74 bytes replaced with jmp + NOPs)')

    print(f'Successfully patched {dst_path}!')

if __name__ == '__main__':
    patch_executable('Notepad4.exe', 'Notepad4_test.exe')
