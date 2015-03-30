# Sortiranje stringa po abecedi (velika slova istog karaktera imaju prednost)
# Primer: 'DabABc521' se sortira u 'AaBbcD125'
# Autor: Ratko Solar - http://ratkosolar.com

.section .data

	unos_stringa_poruka: .ascii "Unesite string za sortiranje:\n\0"
	unos_stringa_poruka_len = . - unos_stringa_poruka

	izlaz_stringa_poruka: .ascii "Sortirani string je:\n\0"
	izlaz_stringa_poruka_len = . - izlaz_stringa_poruka

	string_max_len = 100
	string: .fill 100,1,0
	string_len: .long 0
	
	string_sorted: .fill 100,1,0
	string_sorted_len: .long 0
	
.section .text
.globl main

main:


unos_stringa:	
	# Ispis poruke za unos stringa (isto kao printf)
	movl $4, %eax							
	movl $1, %ebx
	leal unos_stringa_poruka, %ecx
	movl $unos_stringa_poruka_len, %edx
	int $0x80
	
	# Unos stringa preko sistemskog poziva (isto kao scanf)
	movl $3, %eax							
	movl $0, %ebx
	leal string, %ecx
	movl $string_max_len, %edx
	int $0x80
	
	# Duzina stringa unesenog preko sistemskog poziva
	movl %eax, string_len				


#####################################################


# Priprema registara za sortiranje
sortiranje_priprema:						
	movl $string, %eax
	movl string_len, %ebx
	movl $0, %esi
	
	# Ako je duzina stringa jednaka 0, onda je sortiranje zavrseno
	cmpl $0, %ebx
	jle sort_end
	
# Petlja za izbor karaktera koji poredimo sa svim ostalim karakterima
sort_petlja:								
	cmpl %ebx, %esi
	jge sortiranje_priprema
	
	movb (%eax, %esi, 1), %cl
	incl %esi
	movl $0, %edi
	
	# Ako karakter %cl po askijevoj tabeli pripada 'A-Z' sortiraj ga kao velika slova
	# Ako karakter %cl po askijevoj tabeli pripada 'a-z' sortiraj ga kao mala slova
	# Ako nije nijedno od navedenih sortiraj karakter %cl kao ostale karaktere
	cmpb $'A', %cl							 						
	jl sort_ostali_karakteri				
											
	cmpb $'z', %cl
	jg sort_ostali_karakteri
	
	cmpb $'Z', %cl
	jle sort_velika_slova
	
	cmpb $'a', %cl
	jge sort_mala_slova
	
	jmp sort_ostali_karakteri


#####################################################
	
	
# Petlja - ako je trenutni karakter (%cl) veliko slovo
sort_velika_slova:
	cmpl %edi, %ebx
	je sort_prebaci_karakter
	movb (%eax, %edi, 1), %dl
	incl %edi
	
	# Poredi samo sa malim i velikim slovima
	# Ostali karakteri se ignorisu jer slova uvek imaju prednost
	cmpb $'A', %dl
	jl sort_velika_slova
	
	cmpb $'z', %dl
	jg sort_velika_slova
	
	cmpb $'Z', %dl
	jle sort_velika_slova_sa_velikim
	
	cmpb $'a', %dl
	jge sort_velika_slova_sa_malim
	
	jmp sort_velika_slova

# Poredi veliko slovo (%cl) sa velikim slovom (%dl)
sort_velika_slova_sa_velikim:
	cmpb %cl, %dl
	jl sort_petlja
	jmp sort_velika_slova

# Poredi veliko slovo (%cl) sa malim slovom (%dl)
sort_velika_slova_sa_malim:
	# Konvertuje karakter %cl u lowercase radi poredjenja
	addb $'a'-'A', %cl			
	cmpb %cl, %dl
	jl sort_petlja
	
	# Ako petlja nije prekinuta vraca karakter u uppercase
	subb $'a'-'A', %cl			
	jmp sort_velika_slova
	

#####################################################


# Petlja - ako je trenutni karakter (%cl) malo slovo
sort_mala_slova:
	cmpl %edi, %ebx
	je sort_prebaci_karakter
	movb (%eax, %edi, 1), %dl
	incl %edi
	
	# Poredi samo sa malim i velikim slovima
	# Ostali karakteri se ignorisu jer slova uvek imaju prednost
	cmpb $'A', %dl
	jl sort_mala_slova
	
	cmpb $'z', %dl
	jg sort_mala_slova
	
	cmpb $'Z', %dl
	jle sort_mala_slova_sa_velikim
	
	cmpb $'a', %dl
	jge sort_mala_slova_sa_malim
	
	jmp sort_mala_slova

# Poredi malo slovo (%cl) sa velikim slovom (%dl)
sort_mala_slova_sa_velikim:
	# Konvertuje karakter %cl u uppercase radi poredjenja
	subb $'a'-'A', %cl			
	cmpb %cl, %dl
	
	# Ako postoji veliko slovo karaktera %cl prekini petlju
	jle sort_petlja
	
	# Ako petlja nije prekinuta vraca karakter u lowercase
	addb $'a'-'A', %cl			
	jmp sort_mala_slova

# Poredi malo slovo (%cl) sa malim slovom (%dl)
sort_mala_slova_sa_malim:
	cmpb %cl, %dl
	jl sort_petlja
	jmp sort_mala_slova


#####################################################


# Petlja - ako trenutni karakter (%cl) nije ni veliko ni malo slovo	
sort_ostali_karakteri:
	cmpl %edi, %ebx
	je sort_prebaci_karakter
	movb (%eax, %edi, 1), %dl
	incl %edi
	
	# Sprecava sortiranje karaktera za novi red (on ce biti na kraju)
	cmpb $'\n', %dl
	je sort_ostali_karakteri
	
	# Ako u stringu postoje karakteri koji su slova prekini petlju
	# Ako su ostali samo karakteri koji nisu slova poredi ih
	cmpb $'A', %dl
	jl sort_ostali_karakteri_sa_ostalima
	
	cmpb $'z', %dl
	jg sort_ostali_karakteri_sa_ostalima
	
	cmpb $'Z', %dl
	jle sort_petlja
	
	cmpb $'a', %dl
	jge sort_petlja
	
	jmp sort_ostali_karakteri_sa_ostalima

# Poredi karakter koji nije slovo sa istim
sort_ostali_karakteri_sa_ostalima:
	cmpb %cl, %dl
	jl sort_petlja
	jmp sort_ostali_karakteri


#####################################################


# Prebacuje trenutni karakter (%cl) u sortirani string
sort_prebaci_karakter:
	movl $string_sorted, %eax
	movl string_sorted_len, %edi
	movb %cl, (%eax, %edi, 1)
	
	# Priprema za izbacivanje karaktera
	movl $string, %eax
	movl %esi, %edi
	decl %esi	# %esi je bio uvecan za sledeci karakter, zato ga smanjujemo za 1

# Izbacuje trenutni karakter (%cl) iz stringa
sort_string_izbaci_karakter:				
	movb (%eax, %edi, 1), %cl
	movb %cl, (%eax, %esi, 1)
	
	incl %esi
	incl %edi
	
	cmpl %edi, %ebx
	jge sort_string_izbaci_karakter

# Zavrsava shiftovanje stringa i nastavlja sa sortiranjem
sort_string_izbaci_karakter_end:		
	decl string_len	
	incl string_sorted_len
	jmp sortiranje_priprema


#####################################################


sort_end:
	# Ispis poruke za izlaz stringa (isto kao printf)
	movl $4, %eax							
	movl $1, %ebx
	leal izlaz_stringa_poruka, %ecx
	movl $izlaz_stringa_poruka_len, %edx
	int $0x80
	
	# Ispis sortiranog stringa (isto kao printf)
	movl $4, %eax							
	movl $1, %ebx
	leal string_sorted, %ecx
	movl $string_sorted_len, %edx
	int $0x80

end:
	movl $1, %eax
	movl $0, %ebx
	int $0x80
