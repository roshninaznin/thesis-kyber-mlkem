    18af:	xor    %edx,%edx
    18b1:	lea    0x0(,%rdx,8),%r8d
    18b9:	xor    %ecx,%ecx
    18bb:	mov    $0x1,%eax
    18c0:	shl    %cl,%eax
    18c2:	lea    (%rcx,%r8,1),%esi
    18c6:	movw   $0x0,(%rdi,%rsi,2)
    18cc:	and    (%r10,%rdx,1),%al
    18d0:	je     18e6 <mlkem_poly_frommsg+0x3e>
    18d2:	mov    0x674c(%rip),%eax        # 8024 <planted_leak_sink>
    18d8:	movw   $0x681,(%rdi,%rsi,2)
    18de:	inc    %eax
    18e0:	mov    %eax,0x673e(%rip)        # 8024 <planted_leak_sink>
