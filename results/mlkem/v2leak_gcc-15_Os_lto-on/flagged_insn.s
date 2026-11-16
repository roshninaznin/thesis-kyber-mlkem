    3033:	movaps %xmm0,0x2070(%rsp)
    303b:	lea    0x0(,%rdx,8),%esi
    3042:	xor    %ecx,%ecx
    3044:	mov    $0x1,%eax
    3049:	shl    %cl,%eax
    304b:	lea    (%rcx,%rsi,1),%r9d
    304f:	movw   $0x0,0x460(%rsp,%r9,2)
    305a:	and    (%rbx,%rdx,1),%al
    305d:	je     3078 <mlkem_indcpa_enc+0xc8>
    305f:	mov    0x431b(%rip),%eax        # 7380 <planted_leak_sink>
    3065:	movw   $0x681,0x460(%rsp,%r9,2)
    3070:	inc    %eax
    3072:	mov    %eax,0x4308(%rip)        # 7380 <planted_leak_sink>
