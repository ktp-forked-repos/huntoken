# telep�t�si k�nyvt�r a futtathat� programok sz�m�ra

BIN=/usr/bin
MAN=/usr/share/man

# flex -d kapcsol� a tokeniz�l� m�k�d�s�nek nyomk�vet�s�hez
# vegy�k ki megjegyz�sb�l, ha l�p�senk�nt szeretn�nk a tokeniz�l�s
# m�k�d�s�t nyomon k�vetni (l. man flex)

#DEBUG=-d

all: bin/hun_clean bin/hun_sentence bin/hun_abbrev bin/hun_abbrev_en bin/hun_sentclean bin/hun_token bin/hun_latin1 bin/hun_sentbreak

bin/hun_clean:  hun_clean.flex
	@echo hun_clean - karaktereket t�rl�, illetve �talak�t� sz�r�
	-@flex $(DEBUG) hun_clean.flex # -i -> ignore case, -f -8 fast
	@gcc -lfl lex.yy.c -o bin/hun_clean
	@bin/hun_test bin/hun_clean hun_clean.flex test

bin/hun_sentence: hun_sentence.flex
	@echo hun_sentence - mondatra bont� sz�r� 
	-@flex $(DEBUG) hun_sentence.flex # -i -> ignore case, -f -8 fast
	@gcc -lfl lex.yy.c -o bin/hun_sentence
	@bin/hun_test bin/hun_sentence hun_sentence.flex test

bin/hun_abbrev: __hun_abbrev.flex
	@echo hun_abbrev - mondatok �sszevon�sa a val�sz�n�leg hib�s mondathat�rokn�l
	-@flex $(DEBUG) __hun_abbrev.flex # -i -> ignore case, -f -8 fast
	@gcc -lfl lex.yy.c -o bin/hun_abbrev
	@bin/hun_test bin/hun_abbrev __hun_abbrev.flex test

__hun_abbrev.flex: hun_abbrev.flex.m4 data/abbrevations.txt
	@echo r�vid�t�sek automatikus beilleszt�se a flex forr�s l�trehoz�s�val
	@bin/hun_macro M4_MACRO_ABBREV data/abbrevations.txt >__hun_abbrev.flex.m4
	@cat hun_abbrev.flex.m4 >>__hun_abbrev.flex.m4
	@cat __hun_abbrev.flex.m4 | m4 > __hun_abbrev.flex

bin/hun_abbrev_en: __hun_abbrev_en.flex
	@echo 'hun_abbrev_en - mondatok �sszevon�sa a val�sz�n�leg hib�s mondathat�rokn�l (angol)'
	-@flex $(DEBUG) __hun_abbrev_en.flex # -i -> ignore case, -f -8 fast
	@gcc -lfl lex.yy.c -o bin/hun_abbrev_en
	@bin/hun_test bin/hun_abbrev_en __hun_abbrev_en.flex test

__hun_abbrev_en.flex: hun_abbrev_en.flex.m4 data/abbrev_en.txt
	@echo r�vid�t�sek automatikus beilleszt�se a flex forr�s l�trehoz�s�val
	@bin/hun_macro M4_MACRO_ABBREV data/abbrev_en.txt >__hun_abbrev_en.flex.m4
	@cat hun_abbrev_en.flex.m4 >>__hun_abbrev_en.flex.m4
	@cat __hun_abbrev_en.flex.m4 | m4 > __hun_abbrev_en.flex

bin/hun_sentclean: hun_sentclean.flex
	@echo hun_sentclean - mondatra bont�s eredm�ny�t form�zza
	-@flex $(DEBUG) hun_sentclean.flex # -i -> ignore case, -f -8 fast
	@gcc -lfl lex.yy.c -o bin/hun_sentclean
	@bin/hun_test bin/hun_sentclean hun_sentclean.flex test

bin/hun_sentbreak: hun_sentbreak.flex
	@echo hun_sentbreak - hossz� mondatokat t�rdel� sz�r�
	-@flex $(DEBUG) hun_sentbreak.flex # -i -> ignore case, -f -8 fast
	@gcc -lfl lex.yy.c -o bin/hun_sentbreak
	@bin/hun_test bin/hun_sentence hun_sentbreak.flex test

bin/hun_latin1: hun_latin1.flex
	@echo hun_latin1 - latin-1 - latin-2 karakter�talak�t�s
	-@flex $(DEBUG) hun_latin1.flex # -i -> ignore case, -f -8 fast
	@gcc -lfl lex.yy.c -o bin/hun_latin1

bin/hun_token: hun_token.flex
	@echo hun_token - sz�ra bont� �s ny�lttokenoszt�ly-kezel�
	-@flex $(DEBUG) hun_token.flex # -i -> ignore case, -f -8 fast
	@gcc -lfl lex.yy.c -o bin/hun_token
	@bin/hun_test bin/hun_token hun_token.flex test

install:
	@cp bin/huntoken bin/hun_head bin/hun_clean bin/hun_token bin/hun_abbrev \
	  bin/hun_abbrev_en bin/hun_sentclean bin/hun_latin1 bin/hun_sentence $(BIN)
	@test -d $(MAN)/man1 && cp man/huntoken.1 $(MAN)/man1 || echo "$(MAN)/man1 not exist"

deinstall:
	@test -f $(BIN)/huntoken && rm $(BIN)/huntoken || echo "$(BIN)/huntoken not exist"
	@test -f $(BIN)/hun_head && rm $(BIN)/hun_head || echo "$(BIN)/hun_head not exist"
	@test -f $(BIN)/hun_clean && rm $(BIN)/hun_clean || echo "$(BIN)/hun_clean not exist"
	@test -f $(BIN)/hun_token && rm $(BIN)/hun_token || echo "$(BIN)/hun_token not exist"
	@test -f $(BIN)/hun_abbrev && rm $(BIN)/hun_abbrev || echo "$(BIN)/hun_abbrev not exist"
	@test -f $(BIN)/hun_abbrev_en && rm $(BIN)/hun_abbrev_en || echo "$(BIN)/hun_abbrev_en not exist"
	@test -f $(BIN)/hun_sentclean && rm $(BIN)/hun_sentclean || echo "$(BIN)/hun_sentclean not exist"
	@test -f $(BIN)/hun_sentbreak && rm $(BIN)/hun_sentbreak || echo "$(BIN)/hun_sentbreak not exist"
	@test -f $(BIN)/hun_latin1 && rm $(BIN)/hun_latin1 || echo "$(BIN)/hun_latin1 not exist"
	@test -f $(BIN)/hun_sentence && rm $(BIN)/hun_sentence || echo "$(BIN)/hun_sentence not exist"
	@test -f $(MAN)/man1/huntoken.1 && rm $(MAN)/man1/huntoken.1 || echo "$(MAN)/man1/huntoken.1 not exist"
	
clean:
	@rm -f  *.o lex.yy.c test/[!C]*
	@rm -f bin/hun_clean bin/hun_token bin/hun_abbrev bin/hun_abbrev_en \
	   bin/hun_sentclean bin/hun_latin1 bin/hun_sentence bin/hun_sentbreak
	@rm -f __*

test: bin/hun_*
	bin/huntoken <example/HOLTLELKEK.txt >test/HOLTLELKEK.xml
	diff example/HOLTLELKEK.xml test/HOLTLELKEK.xml
