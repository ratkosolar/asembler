# Proverava da li je string palindrom (ignorise karaktere koji nisu slova)
# Primer: String 'An.;;,aVo;LiMilo;.   vana' - jeste palindrom
# Autor: Ratko Solar - http://ratkosolar.com

.section .data

	unos_stringa_poruka: .ascii "Unesite string za proveru da li je palindrom: \0"
	unos_stringa_poruka_len = . - unos_stringa_poruka

	jeste_palindrom_poruka: .ascii "String jeste palindrom\n\0"
	jeste_palindrom_poruka_len = . - jeste_palindrom_poruka

	nije_palindrom_poruka: .ascii "String nije palindrom\n\0"
	nije_palindrom_poruka_len = . - nije_palindrom_poruka

	string_max_len = 100
	string: .fill 100,1,0
	string_len: .long 0
	
	palindrom: .long 0
	
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


# Priprema registre za konvertovanje stringa u uppercase
uppercase_prepare:										
	movl $string, %eax
	movl string_len, %ebx	
	movl $0, %esi
	
# Petlja za pretvaranje stringa u uppercase
uppercase_loop:								
	cmpl %ebx, %esi					
	jnbe remove_otherchars_prepare

uppercase_compare1:
	# Proverava da li je karakter po askijevoj tabeli manji od karaktera 'z'
	cmpb $'z', (%eax, %esi, 1)				
	jbe uppercase_compare2
	
	# Nastavlja petlju (esi++)
	incl %esi								
	jmp uppercase_loop
	
uppercase_compare2:
	# Proverava da li je karakter po askijevoj tabeli veci od karaktera 'a'
	cmpb $'a', (%eax, %esi, 1)				
	jl uppercase_skip
	
	# Konvertuje karakter u uppercase
	subb $'a'-'A', (%eax, %esi, 1)	
			
	# Nastavlja petlju (esi++)
	incl %esi								
	jmp uppercase_loop

uppercase_skip:
	# Nastavlja petlju (esi++)
	incl %esi								
	jmp uppercase_loop


#####################################################


# Brisanje karaktera razlicitih od 'A-Z' iz stringa
remove_otherchars_prepare:					
	movl string_len, %ebx	
	movl %ebx, %esi
	movl %ebx, %edi
	incl %edi

# Petlja kroz string od nazad
remove_otherchars_loop:						
	decl %esi
	decl %edi
	
	cmpl $0, %esi					
	jl palindrom_prepare

# Nastavi petlju ako je karakter izmedju 'A' i 'Z' u suprotnom izbaci karakter
remove_otherchars_compare:					
	cmpb $'A', (%eax, %esi, 1)
	jb remove_otherchars_shift
	
	cmpb $'Z', (%eax, %esi, 1)
	jg remove_otherchars_shift
	
	jmp remove_otherchars_loop

# Izbacuje trenutni karakter iz stringa (string_len se smanjuje za 1)
remove_otherchars_shift:					
	movb 0(%eax, %edi, 1), %cl
	movb %cl, (%eax, %esi, 1)
	
	incl %esi
	incl %edi
	
	cmpl %edi, %ebx
	jge remove_otherchars_shift

# string_len--
remove_otherchars_shift_end:				
	decl string_len	
	jmp remove_otherchars_prepare
	
	
#####################################################

		
# Proverava da li je string palindrom
palindrom_prepare:							
	movl string_len, %ebx	
	movl $0, %esi
	movl %ebx, %edi
	decl %edi

# Proverava da li je string palindrom
palindrom_provera:							
	movb (%eax, %esi, 1), %cl				
	movb (%eax, %edi, 1), %dl
	
	cmpb %cl, %dl
	jne palindrom_nije
	
	incl %esi
	decl %edi
	cmpl %esi, %edi
	jb palindrom_jeste
	
	jmp palindrom_provera
	
	
#####################################################


# Priprema poruku za "jeste palindrom"
palindrom_jeste:							
	leal jeste_palindrom_poruka, %ecx
	movl $jeste_palindrom_poruka_len, %edx
	jmp palindrom_poruka
	
# Priprema poruku za "nije palindrom"
palindrom_nije:								
	leal nije_palindrom_poruka, %ecx
	movl $nije_palindrom_poruka_len, %edx
	jmp palindrom_poruka

# Ispisuje poruku preko sistemskog poziva
palindrom_poruka:							
	movl $4, %eax							
	movl $1, %ebx
	int $0x80

end:
	movl $1, %eax
	movl $0, %ebx
	int $0x80
