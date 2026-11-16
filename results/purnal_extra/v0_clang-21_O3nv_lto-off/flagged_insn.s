    25b8:	nopl   0x0(%rax,%rax,1)
    25c0:	mov    %cx,(%rdi)
    25c3:	inc    %rax
    25c6:	add    $0x10,%rdi
    25ca:	cmp    $0x20,%rax
    25ce:	je     2722 <pqcrystals_kyber512_ref_poly_frommsg+0x172>
    25d4:	testb  $0x1,(%rsi,%rax,1)
    25d8:	mov    $0x0,%ecx
    25dd:	jne    2670 <pqcrystals_kyber512_ref_poly_frommsg+0xc0>
    25e3:	mov    %cx,-0xe(%rdi)
    25e7:	testb  $0x2,(%rsi,%rax,1)
    25eb:	mov    $0x0,%ecx
    25f0:	jne    2688 <pqcrystals_kyber512_ref_poly_frommsg+0xd8>
    25ca:	cmp    $0x20,%rax
    25ce:	je     2722 <pqcrystals_kyber512_ref_poly_frommsg+0x172>
    25d4:	testb  $0x1,(%rsi,%rax,1)
    25d8:	mov    $0x0,%ecx
    25dd:	jne    2670 <pqcrystals_kyber512_ref_poly_frommsg+0xc0>
    25e3:	mov    %cx,-0xe(%rdi)
    25e7:	testb  $0x2,(%rsi,%rax,1)
    25eb:	mov    $0x0,%ecx
    25f0:	jne    2688 <pqcrystals_kyber512_ref_poly_frommsg+0xd8>
    25f6:	mov    %cx,-0xc(%rdi)
    25fa:	testb  $0x4,(%rsi,%rax,1)
    25fe:	mov    $0x0,%ecx
    2603:	jne    26a0 <pqcrystals_kyber512_ref_poly_frommsg+0xf0>
    25dd:	jne    2670 <pqcrystals_kyber512_ref_poly_frommsg+0xc0>
    25e3:	mov    %cx,-0xe(%rdi)
    25e7:	testb  $0x2,(%rsi,%rax,1)
    25eb:	mov    $0x0,%ecx
    25f0:	jne    2688 <pqcrystals_kyber512_ref_poly_frommsg+0xd8>
    25f6:	mov    %cx,-0xc(%rdi)
    25fa:	testb  $0x4,(%rsi,%rax,1)
    25fe:	mov    $0x0,%ecx
    2603:	jne    26a0 <pqcrystals_kyber512_ref_poly_frommsg+0xf0>
    2609:	mov    %cx,-0xa(%rdi)
    260d:	testb  $0x8,(%rsi,%rax,1)
    2611:	mov    $0x0,%ecx
    2616:	jne    26b8 <pqcrystals_kyber512_ref_poly_frommsg+0x108>
    25f0:	jne    2688 <pqcrystals_kyber512_ref_poly_frommsg+0xd8>
    25f6:	mov    %cx,-0xc(%rdi)
    25fa:	testb  $0x4,(%rsi,%rax,1)
    25fe:	mov    $0x0,%ecx
    2603:	jne    26a0 <pqcrystals_kyber512_ref_poly_frommsg+0xf0>
    2609:	mov    %cx,-0xa(%rdi)
    260d:	testb  $0x8,(%rsi,%rax,1)
    2611:	mov    $0x0,%ecx
    2616:	jne    26b8 <pqcrystals_kyber512_ref_poly_frommsg+0x108>
    261c:	mov    %cx,-0x8(%rdi)
    2620:	testb  $0x10,(%rsi,%rax,1)
    2624:	mov    $0x0,%ecx
    2629:	jne    26d0 <pqcrystals_kyber512_ref_poly_frommsg+0x120>
    2603:	jne    26a0 <pqcrystals_kyber512_ref_poly_frommsg+0xf0>
    2609:	mov    %cx,-0xa(%rdi)
    260d:	testb  $0x8,(%rsi,%rax,1)
    2611:	mov    $0x0,%ecx
    2616:	jne    26b8 <pqcrystals_kyber512_ref_poly_frommsg+0x108>
    261c:	mov    %cx,-0x8(%rdi)
    2620:	testb  $0x10,(%rsi,%rax,1)
    2624:	mov    $0x0,%ecx
    2629:	jne    26d0 <pqcrystals_kyber512_ref_poly_frommsg+0x120>
    262f:	mov    %cx,-0x6(%rdi)
    2633:	testb  $0x20,(%rsi,%rax,1)
    2637:	mov    $0x0,%ecx
    263c:	jne    26e8 <pqcrystals_kyber512_ref_poly_frommsg+0x138>
    2616:	jne    26b8 <pqcrystals_kyber512_ref_poly_frommsg+0x108>
    261c:	mov    %cx,-0x8(%rdi)
    2620:	testb  $0x10,(%rsi,%rax,1)
    2624:	mov    $0x0,%ecx
    2629:	jne    26d0 <pqcrystals_kyber512_ref_poly_frommsg+0x120>
    262f:	mov    %cx,-0x6(%rdi)
    2633:	testb  $0x20,(%rsi,%rax,1)
    2637:	mov    $0x0,%ecx
    263c:	jne    26e8 <pqcrystals_kyber512_ref_poly_frommsg+0x138>
    2642:	mov    %cx,-0x4(%rdi)
    2646:	testb  $0x40,(%rsi,%rax,1)
    264a:	mov    $0x0,%ecx
    264f:	jne    2700 <pqcrystals_kyber512_ref_poly_frommsg+0x150>
    2629:	jne    26d0 <pqcrystals_kyber512_ref_poly_frommsg+0x120>
    262f:	mov    %cx,-0x6(%rdi)
    2633:	testb  $0x20,(%rsi,%rax,1)
    2637:	mov    $0x0,%ecx
    263c:	jne    26e8 <pqcrystals_kyber512_ref_poly_frommsg+0x138>
    2642:	mov    %cx,-0x4(%rdi)
    2646:	testb  $0x40,(%rsi,%rax,1)
    264a:	mov    $0x0,%ecx
    264f:	jne    2700 <pqcrystals_kyber512_ref_poly_frommsg+0x150>
    2655:	mov    %cx,-0x2(%rdi)
    2659:	cmpb   $0x0,(%rsi,%rax,1)
    265d:	mov    $0x0,%ecx
    2662:	jns    25c0 <pqcrystals_kyber512_ref_poly_frommsg+0x10>
    263c:	jne    26e8 <pqcrystals_kyber512_ref_poly_frommsg+0x138>
    2642:	mov    %cx,-0x4(%rdi)
    2646:	testb  $0x40,(%rsi,%rax,1)
    264a:	mov    $0x0,%ecx
    264f:	jne    2700 <pqcrystals_kyber512_ref_poly_frommsg+0x150>
    2655:	mov    %cx,-0x2(%rdi)
    2659:	cmpb   $0x0,(%rsi,%rax,1)
    265d:	mov    $0x0,%ecx
    2662:	jns    25c0 <pqcrystals_kyber512_ref_poly_frommsg+0x10>
    2668:	jmp    2718 <pqcrystals_kyber512_ref_poly_frommsg+0x168>
    266d:	nopl   (%rax)
    2670:	mov    $0x681,%ecx
    2675:	mov    %cx,-0xe(%rdi)
    265d:	mov    $0x0,%ecx
    2662:	jns    25c0 <pqcrystals_kyber512_ref_poly_frommsg+0x10>
    2668:	jmp    2718 <pqcrystals_kyber512_ref_poly_frommsg+0x168>
    266d:	nopl   (%rax)
    2670:	mov    $0x681,%ecx
    2675:	mov    %cx,-0xe(%rdi)
    2679:	testb  $0x2,(%rsi,%rax,1)
    267d:	mov    $0x0,%ecx
    2682:	je     25f6 <pqcrystals_kyber512_ref_poly_frommsg+0x46>
    2688:	mov    $0x681,%ecx
    268d:	mov    %cx,-0xc(%rdi)
    2691:	testb  $0x4,(%rsi,%rax,1)
    2695:	mov    $0x0,%ecx
    2675:	mov    %cx,-0xe(%rdi)
    2679:	testb  $0x2,(%rsi,%rax,1)
    267d:	mov    $0x0,%ecx
    2682:	je     25f6 <pqcrystals_kyber512_ref_poly_frommsg+0x46>
    2688:	mov    $0x681,%ecx
    268d:	mov    %cx,-0xc(%rdi)
    2691:	testb  $0x4,(%rsi,%rax,1)
    2695:	mov    $0x0,%ecx
    269a:	je     2609 <pqcrystals_kyber512_ref_poly_frommsg+0x59>
    26a0:	mov    $0x681,%ecx
    26a5:	mov    %cx,-0xa(%rdi)
    26a9:	testb  $0x8,(%rsi,%rax,1)
    26ad:	mov    $0x0,%ecx
    268d:	mov    %cx,-0xc(%rdi)
    2691:	testb  $0x4,(%rsi,%rax,1)
    2695:	mov    $0x0,%ecx
    269a:	je     2609 <pqcrystals_kyber512_ref_poly_frommsg+0x59>
    26a0:	mov    $0x681,%ecx
    26a5:	mov    %cx,-0xa(%rdi)
    26a9:	testb  $0x8,(%rsi,%rax,1)
    26ad:	mov    $0x0,%ecx
    26b2:	je     261c <pqcrystals_kyber512_ref_poly_frommsg+0x6c>
    26b8:	mov    $0x681,%ecx
    26bd:	mov    %cx,-0x8(%rdi)
    26c1:	testb  $0x10,(%rsi,%rax,1)
    26c5:	mov    $0x0,%ecx
    26a5:	mov    %cx,-0xa(%rdi)
    26a9:	testb  $0x8,(%rsi,%rax,1)
    26ad:	mov    $0x0,%ecx
    26b2:	je     261c <pqcrystals_kyber512_ref_poly_frommsg+0x6c>
    26b8:	mov    $0x681,%ecx
    26bd:	mov    %cx,-0x8(%rdi)
    26c1:	testb  $0x10,(%rsi,%rax,1)
    26c5:	mov    $0x0,%ecx
    26ca:	je     262f <pqcrystals_kyber512_ref_poly_frommsg+0x7f>
    26d0:	mov    $0x681,%ecx
    26d5:	mov    %cx,-0x6(%rdi)
    26d9:	testb  $0x20,(%rsi,%rax,1)
    26dd:	mov    $0x0,%ecx
    26bd:	mov    %cx,-0x8(%rdi)
    26c1:	testb  $0x10,(%rsi,%rax,1)
    26c5:	mov    $0x0,%ecx
    26ca:	je     262f <pqcrystals_kyber512_ref_poly_frommsg+0x7f>
    26d0:	mov    $0x681,%ecx
    26d5:	mov    %cx,-0x6(%rdi)
    26d9:	testb  $0x20,(%rsi,%rax,1)
    26dd:	mov    $0x0,%ecx
    26e2:	je     2642 <pqcrystals_kyber512_ref_poly_frommsg+0x92>
    26e8:	mov    $0x681,%ecx
    26ed:	mov    %cx,-0x4(%rdi)
    26f1:	testb  $0x40,(%rsi,%rax,1)
    26f5:	mov    $0x0,%ecx
    26d5:	mov    %cx,-0x6(%rdi)
    26d9:	testb  $0x20,(%rsi,%rax,1)
    26dd:	mov    $0x0,%ecx
    26e2:	je     2642 <pqcrystals_kyber512_ref_poly_frommsg+0x92>
    26e8:	mov    $0x681,%ecx
    26ed:	mov    %cx,-0x4(%rdi)
    26f1:	testb  $0x40,(%rsi,%rax,1)
    26f5:	mov    $0x0,%ecx
    26fa:	je     2655 <pqcrystals_kyber512_ref_poly_frommsg+0xa5>
    2700:	mov    $0x681,%ecx
    2705:	mov    %cx,-0x2(%rdi)
    2709:	cmpb   $0x0,(%rsi,%rax,1)
    270d:	mov    $0x0,%ecx
    26ed:	mov    %cx,-0x4(%rdi)
    26f1:	testb  $0x40,(%rsi,%rax,1)
    26f5:	mov    $0x0,%ecx
    26fa:	je     2655 <pqcrystals_kyber512_ref_poly_frommsg+0xa5>
    2700:	mov    $0x681,%ecx
    2705:	mov    %cx,-0x2(%rdi)
    2709:	cmpb   $0x0,(%rsi,%rax,1)
    270d:	mov    $0x0,%ecx
    2712:	jns    25c0 <pqcrystals_kyber512_ref_poly_frommsg+0x10>
    2718:	mov    $0x681,%ecx
    271d:	jmp    25c0 <pqcrystals_kyber512_ref_poly_frommsg+0x10>
    2722:	ret
    2723:	data16 data16 data16 cs nopw 0x0(%rax,%rax,1)
