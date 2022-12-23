#!/bin/bash

LimparECriarDir() {		# Uma função simples para economizar algumas linhas
	rm -r $1 &>/dev/null
	mkdir $1
}

TransformarArquivo() {		# Uma função que transforma um arquivo e deixa todas as letras maiusculas
	sed -i 's/\d00//g' ./156/CSVs/$1
	iconv -f 'ISO8859-1' -t UTF8 ./156/CSVs/$1 -o ./156/CSVs/'UTF8-'$1
	sed -i 's/./\U&/g' ./156/CSVs/'UTF8-'$1
}

#Obtenção dos dados no site proposto
LimparECriarDir ./156
wget http://dadosabertos.c3sl.ufpr.br/curitiba/156/ -O ./156/index.html

#Obtenção dos arquivos base para a filtragem
csvFileUrls=$(cat ./156/index.html | grep csv | cut -d'"' -f8 | grep 2021 | grep -v -e{_201,Historico})		# Essa variavel sera uma lista com todos os arquivos csv
LimparECriarDir ./156/CSVs

for tempForLoopValue in $csvFileUrls
do
	curl "http://dadosabertos.c3sl.ufpr.br/curitiba/156/$tempForLoopValue" > ./156/CSVs/$tempForLoopValue	# Esse for loop baixa os arquivos da lista
done

#Mudar o charset dos arquivos CSV para 8 bit
for tempForLoopValue in $csvFileUrls
do
	echo 'removendo simbolos do arquivo: '$tempForLoopValue							# Um Echo simples para descrever oque está ocorrendo
	TransformarArquivo $tempForLoopValue									# transformar arquivos para UTF8 e deixar tudo maiusculo
	rm ./156/CSVs/$tempForLoopValue										# Remover arquivos base originais que não são mais usados
done

#Obter os 2 arquivos 'ASSUNTOS.txt' e SUBDIVISAO.txt
for tempForLoopValue in $csvFileUrls
do
	cat ./156/CSVs/'UTF8-'$tempForLoopValue | cut -d';' -f6 | tail -n +3 >> ./156/ASSUNTO.txt		# Extrai a sexta coluna(assunto) para o arquivo ASSUNTO
	cat ./156/CSVs/'UTF8-'$tempForLoopValue | cut -d';' -f7 | tail -n +3 >> ./156/SUBDIVISAO.txt		# Extrai agora a setima coluna para o arquivo SUBDIVISAO
done

sort -f ./156/ASSUNTO.txt | sed '/^$/d' | uniq -c | sort -rgo ./156/ASSUNTO.txt					# Por fim, filtra e limpa os arquivos assim como ordena eles.
sort -f ./156/SUBDIVISAO.txt | sed '/^$/d' | uniq -c | sort -rgo ./156/SUBDIVISAO.txt

#remover variaveis usadas
unset csvFileUrls
unset tempForLoopValue
