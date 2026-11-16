    25e8:	nopl   0x0(%rax,%rax,1)
    25f0:	mov    %cx,(%rdi)
    25f3:	inc    %rax
    25f6:	add    $0x10,%rdi
    25fa:	cmp    $0x20,%rax
    25fe:	je     2752 <pqcrystals_kyber512_ref_poly_frommsg+0x172>
    2604:	testb  $0x1,(%rsi,%rax,1)
    2608:	mov    $0x0,%ecx
    260d:	jne    26a0 <pqcrystals_kyber512_ref_poly_frommsg+0xc0>
    2613:	mov    %cx,-0xe(%rdi)
    2617:	testb  $0x2,(%rsi,%rax,1)
    261b:	mov    $0x0,%ecx
    2620:	jne    26b8 <pqcrystals_kyber512_ref_poly_frommsg+0xd8>
    25fa:	cmp    $0x20,%rax
    25fe:	je     2752 <pqcrystals_kyber512_ref_poly_frommsg+0x172>
    2604:	testb  $0x1,(%rsi,%rax,1)
    2608:	mov    $0x0,%ecx
    260d:	jne    26a0 <pqcrystals_kyber512_ref_poly_frommsg+0xc0>
    2613:	mov    %cx,-0xe(%rdi)
    2617:	testb  $0x2,(%rsi,%rax,1)
    261b:	mov    $0x0,%ecx
    2620:	jne    26b8 <pqcrystals_kyber512_ref_poly_frommsg+0xd8>
    2626:	mov    %cx,-0xc(%rdi)
    262a:	testb  $0x4,(%rsi,%rax,1)
    262e:	mov    $0x0,%ecx
    2633:	jne    26d0 <pqcrystals_kyber512_ref_poly_frommsg+0xf0>
    260d:	jne    26a0 <pqcrystals_kyber512_ref_poly_frommsg+0xc0>
    2613:	mov    %cx,-0xe(%rdi)
    2617:	testb  $0x2,(%rsi,%rax,1)
    261b:	mov    $0x0,%ecx
    2620:	jne    26b8 <pqcrystals_kyber512_ref_poly_frommsg+0xd8>
    2626:	mov    %cx,-0xc(%rdi)
    262a:	testb  $0x4,(%rsi,%rax,1)
    262e:	mov    $0x0,%ecx
    2633:	jne    26d0 <pqcrystals_kyber512_ref_poly_frommsg+0xf0>
    2639:	mov    %cx,-0xa(%rdi)
    263d:	testb  $0x8,(%rsi,%rax,1)
    2641:	mov    $0x0,%ecx
    2646:	jne    26e8 <pqcrystals_kyber512_ref_poly_frommsg+0x108>
    2620:	jne    26b8 <pqcrystals_kyber512_ref_poly_frommsg+0xd8>
    2626:	mov    %cx,-0xc(%rdi)
    262a:	testb  $0x4,(%rsi,%rax,1)
    262e:	mov    $0x0,%ecx
    2633:	jne    26d0 <pqcrystals_kyber512_ref_poly_frommsg+0xf0>
    2639:	mov    %cx,-0xa(%rdi)
    263d:	testb  $0x8,(%rsi,%rax,1)
    2641:	mov    $0x0,%ecx
    2646:	jne    26e8 <pqcrystals_kyber512_ref_poly_frommsg+0x108>
    264c:	mov    %cx,-0x8(%rdi)
    2650:	testb  $0x10,(%rsi,%rax,1)
    2654:	mov    $0x0,%ecx
    2659:	jne    2700 <pqcrystals_kyber512_ref_poly_frommsg+0x120>
    2633:	jne    26d0 <pqcrystals_kyber512_ref_poly_frommsg+0xf0>
    2639:	mov    %cx,-0xa(%rdi)
    263d:	testb  $0x8,(%rsi,%rax,1)
    2641:	mov    $0x0,%ecx
    2646:	jne    26e8 <pqcrystals_kyber512_ref_poly_frommsg+0x108>
    264c:	mov    %cx,-0x8(%rdi)
    2650:	testb  $0x10,(%rsi,%rax,1)
    2654:	mov    $0x0,%ecx
    2659:	jne    2700 <pqcrystals_kyber512_ref_poly_frommsg+0x120>
    265f:	mov    %cx,-0x6(%rdi)
    2663:	testb  $0x20,(%rsi,%rax,1)
    2667:	mov    $0x0,%ecx
    266c:	jne    2718 <pqcrystals_kyber512_ref_poly_frommsg+0x138>
    2646:	jne    26e8 <pqcrystals_kyber512_ref_poly_frommsg+0x108>
    264c:	mov    %cx,-0x8(%rdi)
    2650:	testb  $0x10,(%rsi,%rax,1)
    2654:	mov    $0x0,%ecx
    2659:	jne    2700 <pqcrystals_kyber512_ref_poly_frommsg+0x120>
    265f:	mov    %cx,-0x6(%rdi)
    2663:	testb  $0x20,(%rsi,%rax,1)
    2667:	mov    $0x0,%ecx
    266c:	jne    2718 <pqcrystals_kyber512_ref_poly_frommsg+0x138>
    2672:	mov    %cx,-0x4(%rdi)
    2676:	testb  $0x40,(%rsi,%rax,1)
    267a:	mov    $0x0,%ecx
    267f:	jne    2730 <pqcrystals_kyber512_ref_poly_frommsg+0x150>
    2659:	jne    2700 <pqcrystals_kyber512_ref_poly_frommsg+0x120>
    265f:	mov    %cx,-0x6(%rdi)
    2663:	testb  $0x20,(%rsi,%rax,1)
    2667:	mov    $0x0,%ecx
    266c:	jne    2718 <pqcrystals_kyber512_ref_poly_frommsg+0x138>
    2672:	mov    %cx,-0x4(%rdi)
    2676:	testb  $0x40,(%rsi,%rax,1)
    267a:	mov    $0x0,%ecx
    267f:	jne    2730 <pqcrystals_kyber512_ref_poly_frommsg+0x150>
    2685:	mov    %cx,-0x2(%rdi)
    2689:	cmpb   $0x0,(%rsi,%rax,1)
    268d:	mov    $0x0,%ecx
    2692:	jns    25f0 <pqcrystals_kyber512_ref_poly_frommsg+0x10>
    266c:	jne    2718 <pqcrystals_kyber512_ref_poly_frommsg+0x138>
    2672:	mov    %cx,-0x4(%rdi)
    2676:	testb  $0x40,(%rsi,%rax,1)
    267a:	mov    $0x0,%ecx
    267f:	jne    2730 <pqcrystals_kyber512_ref_poly_frommsg+0x150>
    2685:	mov    %cx,-0x2(%rdi)
    2689:	cmpb   $0x0,(%rsi,%rax,1)
    268d:	mov    $0x0,%ecx
    2692:	jns    25f0 <pqcrystals_kyber512_ref_poly_frommsg+0x10>
    2698:	jmp    2748 <pqcrystals_kyber512_ref_poly_frommsg+0x168>
    269d:	nopl   (%rax)
    26a0:	mov    $0x681,%ecx
    26a5:	mov    %cx,-0xe(%rdi)
    268d:	mov    $0x0,%ecx
    2692:	jns    25f0 <pqcrystals_kyber512_ref_poly_frommsg+0x10>
    2698:	jmp    2748 <pqcrystals_kyber512_ref_poly_frommsg+0x168>
    269d:	nopl   (%rax)
    26a0:	mov    $0x681,%ecx
    26a5:	mov    %cx,-0xe(%rdi)
    26a9:	testb  $0x2,(%rsi,%rax,1)
    26ad:	mov    $0x0,%ecx
    26b2:	je     2626 <pqcrystals_kyber512_ref_poly_frommsg+0x46>
    26b8:	mov    $0x681,%ecx
    26bd:	mov    %cx,-0xc(%rdi)
    26c1:	testb  $0x4,(%rsi,%rax,1)
    26c5:	mov    $0x0,%ecx
    26a5:	mov    %cx,-0xe(%rdi)
    26a9:	testb  $0x2,(%rsi,%rax,1)
    26ad:	mov    $0x0,%ecx
    26b2:	je     2626 <pqcrystals_kyber512_ref_poly_frommsg+0x46>
    26b8:	mov    $0x681,%ecx
    26bd:	mov    %cx,-0xc(%rdi)
    26c1:	testb  $0x4,(%rsi,%rax,1)
    26c5:	mov    $0x0,%ecx
    26ca:	je     2639 <pqcrystals_kyber512_ref_poly_frommsg+0x59>
    26d0:	mov    $0x681,%ecx
    26d5:	mov    %cx,-0xa(%rdi)
    26d9:	testb  $0x8,(%rsi,%rax,1)
    26dd:	mov    $0x0,%ecx
    26bd:	mov    %cx,-0xc(%rdi)
    26c1:	testb  $0x4,(%rsi,%rax,1)
    26c5:	mov    $0x0,%ecx
    26ca:	je     2639 <pqcrystals_kyber512_ref_poly_frommsg+0x59>
    26d0:	mov    $0x681,%ecx
    26d5:	mov    %cx,-0xa(%rdi)
    26d9:	testb  $0x8,(%rsi,%rax,1)
    26dd:	mov    $0x0,%ecx
    26e2:	je     264c <pqcrystals_kyber512_ref_poly_frommsg+0x6c>
    26e8:	mov    $0x681,%ecx
    26ed:	mov    %cx,-0x8(%rdi)
    26f1:	testb  $0x10,(%rsi,%rax,1)
    26f5:	mov    $0x0,%ecx
    26d5:	mov    %cx,-0xa(%rdi)
    26d9:	testb  $0x8,(%rsi,%rax,1)
    26dd:	mov    $0x0,%ecx
    26e2:	je     264c <pqcrystals_kyber512_ref_poly_frommsg+0x6c>
    26e8:	mov    $0x681,%ecx
    26ed:	mov    %cx,-0x8(%rdi)
    26f1:	testb  $0x10,(%rsi,%rax,1)
    26f5:	mov    $0x0,%ecx
    26fa:	je     265f <pqcrystals_kyber512_ref_poly_frommsg+0x7f>
    2700:	mov    $0x681,%ecx
    2705:	mov    %cx,-0x6(%rdi)
    2709:	testb  $0x20,(%rsi,%rax,1)
    270d:	mov    $0x0,%ecx
    26ed:	mov    %cx,-0x8(%rdi)
    26f1:	testb  $0x10,(%rsi,%rax,1)
    26f5:	mov    $0x0,%ecx
    26fa:	je     265f <pqcrystals_kyber512_ref_poly_frommsg+0x7f>
    2700:	mov    $0x681,%ecx
    2705:	mov    %cx,-0x6(%rdi)
    2709:	testb  $0x20,(%rsi,%rax,1)
    270d:	mov    $0x0,%ecx
    2712:	je     2672 <pqcrystals_kyber512_ref_poly_frommsg+0x92>
    2718:	mov    $0x681,%ecx
    271d:	mov    %cx,-0x4(%rdi)
    2721:	testb  $0x40,(%rsi,%rax,1)
    2725:	mov    $0x0,%ecx
    2705:	mov    %cx,-0x6(%rdi)
    2709:	testb  $0x20,(%rsi,%rax,1)
    270d:	mov    $0x0,%ecx
    2712:	je     2672 <pqcrystals_kyber512_ref_poly_frommsg+0x92>
    2718:	mov    $0x681,%ecx
    271d:	mov    %cx,-0x4(%rdi)
    2721:	testb  $0x40,(%rsi,%rax,1)
    2725:	mov    $0x0,%ecx
    272a:	je     2685 <pqcrystals_kyber512_ref_poly_frommsg+0xa5>
    2730:	mov    $0x681,%ecx
    2735:	mov    %cx,-0x2(%rdi)
    2739:	cmpb   $0x0,(%rsi,%rax,1)
    273d:	mov    $0x0,%ecx
    271d:	mov    %cx,-0x4(%rdi)
    2721:	testb  $0x40,(%rsi,%rax,1)
    2725:	mov    $0x0,%ecx
    272a:	je     2685 <pqcrystals_kyber512_ref_poly_frommsg+0xa5>
    2730:	mov    $0x681,%ecx
    2735:	mov    %cx,-0x2(%rdi)
    2739:	cmpb   $0x0,(%rsi,%rax,1)
    273d:	mov    $0x0,%ecx
    2742:	jns    25f0 <pqcrystals_kyber512_ref_poly_frommsg+0x10>
    2748:	mov    $0x681,%ecx
    274d:	jmp    25f0 <pqcrystals_kyber512_ref_poly_frommsg+0x10>
    2752:	ret
    2753:	data16 data16 data16 cs nopw 0x0(%rax,%rax,1)
