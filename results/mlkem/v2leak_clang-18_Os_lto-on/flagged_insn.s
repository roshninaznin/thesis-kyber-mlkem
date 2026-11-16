    3ec4:	movaps %xmm0,0x20(%rsp)
    3ec9:	lea    0xa40(%rsp),%rax
    3ed1:	xor    %edx,%edx
    3ed3:	xor    %ecx,%ecx
    3ed5:	mov    $0x1,%esi
    3eda:	shl    %cl,%esi
    3edc:	movw   $0x0,(%rax,%rcx,2)
    3ee2:	test   %sil,(%r14,%rdx,1)
    3ee6:	je     3ef4 <mlkem_indcpa_enc+0x8f>
    3ee8:	incl   0x41a6(%rip)        # 8094 <planted_leak_sink>
    3eee:	movw   $0x681,(%rax,%rcx,2)
    3ef4:	inc    %rcx
    3ef7:	cmp    $0x8,%rcx
