    3f05:	movaps %xmm0,0x20(%rsp)
    3f0a:	lea    0xa40(%rsp),%rax
    3f12:	xor    %edx,%edx
    3f14:	xor    %ecx,%ecx
    3f16:	mov    $0x1,%esi
    3f1b:	shl    %cl,%esi
    3f1d:	movw   $0x0,(%rax,%rcx,2)
    3f23:	test   %sil,(%r14,%rdx,1)
    3f27:	je     3f35 <mlkem_indcpa_enc+0x8f>
    3f29:	incl   0x41c5(%rip)        # 80f4 <planted_leak_sink>
    3f2f:	movw   $0x681,(%rax,%rcx,2)
    3f35:	inc    %rcx
    3f38:	cmp    $0x8,%rcx
